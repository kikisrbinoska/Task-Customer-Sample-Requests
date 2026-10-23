codeunit 50100 "Sample Request Mgt."
{
    trigger OnRun()
    begin

    end;

    procedure CheckNotBlockedCustomer(CustomerNo: Code[20])
    var
        Customer: Record Customer;
        CustomerBlockedErr: Label 'Customer %1 is blocked with status %2, chose another costumer or try to unblock it', Comment = '%1 = customer no., %2 = value of the Blocked field';
    begin
        Customer.Get(CustomerNo);
        if Customer.Blocked <> Customer.Blocked::" " then
            Error(CustomerBlockedErr, CustomerNo, Customer.Blocked);
    end;

    procedure CheckItemAllowed(ItemNo: Code[20])
    var
        Item: Record Item;
        ItemNotAllowedErr: Label 'Item %1 is not allowed, Sample Allowed need to be turned on or try to chose another item', Comment = '%1 = item no.';
    begin
        Item.Get(ItemNo);
        Item.TestField(Blocked, false);
        if not Item."Sample Allowed" then
            Error(ItemNotAllowedErr, ItemNo);
    end;

    procedure GetMaxSampleQuantity(ItemNo: Code[20]): Decimal
    var
        Item: Record Item;
        SampleRequestSetup: Record "Sample Request Setup";
    begin
        Item.Get(ItemNo);
        if Item."Max. Sample Qty." <> 0 then
            exit(Item."Max. Sample Qty.");
        SampleRequestSetup.Get();
        exit(SampleRequestSetup."Default Max. Sample Qty.")
    end;

    procedure CheckQuantity(ItemNo: Code[20]; Quantity: Decimal)
    var
        MaxQuantity: Decimal;
        QuantityIsNotPositiveErr: Label 'The quantity must be greater than 0. Enter a positive quantity.';
        QuantityIsAboveMaxErr: Label 'The quantity cannot be more than %1 for item %2. Enter a quantity of %1 or less.', Comment = '%1 = maximum sample quantity, %2 = item no.';

        QuantityNotAllowedErr: Label 'Quantity can not be more than %1 for %2', Comment = '%1 = max quantity., %2 = value of the item no.';
    begin
        if Quantity <= 0 then
            Error(QuantityIsNotPositiveErr);
        MaxQuantity := GetMaxSampleQuantity(ItemNo);
        if (MaxQuantity > 0) and (Quantity > MaxQuantity) then
            Error(QuantityIsAboveMaxErr, MaxQuantity, ItemNo);
    end;

    procedure CheckLines(var SampleRequest: Record "Sample Request Header")
    var
        SampleRequestLine: Record "Sample Request Line";
        NoLinesErr: Label 'Sample request %1 has no lines. Add at least one line before you submit it.', Comment = '%1 = sample request no.';
        LineWithoutItemErr: Label 'Line %1 on sample request %2 has no item. Enter an item or delete the line.', Comment = '%1 = line no., %2 = sample request no.';
        LineWithoutQuantityErr: Label 'Item %1 on sample request %2 has no quantity. Enter a quantity above 0.', Comment = '%1 = item no., %2 = sample request no.';
    begin
        SampleRequestLine.SetRange("Document No.", SampleRequest."No.");
        if SampleRequestLine.IsEmpty() then
            Error(NoLinesErr, SampleRequest."No.");

        SampleRequestLine.SetRange("Item No.", '');
        if SampleRequestLine.FindFirst() then
            Error(LineWithoutItemErr, SampleRequestLine."Line No.", SampleRequest."No.");

        SampleRequestLine.SetRange("Item No.");
        SampleRequestLine.SetFilter(Quantity, '<=0');
        if SampleRequestLine.FindFirst() then
            Error(LineWithoutQuantityErr, SampleRequestLine."Item No.", SampleRequest."No.");
    end;

    procedure CheckNoLinesExist(var SampleRequest: Record "Sample Request Header")
    var
        SampleRequestLine: Record "Sample Request Line";
        LinesExistErr: Label 'You cannot change the customer on sample request %1 because it already has lines. Delete the lines first.', Comment = '%1 = sample request no.';
    begin
        SampleRequestLine.SetRange("Document No.", SampleRequest."No.");
        if not SampleRequestLine.IsEmpty() then
            Error(LinesExistErr);
    end;

    procedure CheckMaxRequestsPerPeriod(SampleRequest: Record "Sample Request Header")
    var
        SampleRequestSetup: Record "Sample Request Setup";
        OtherRequest: Record "Sample Request Header";
        StartPeriod: Date;
        RequestCount: Integer;
        TooManyRequestsErr: Label 'Customer %1 already has %2 sample requests since %3. The maximum is %4.', Comment = '%1 = customer no., %2 = number of requests, %3 = start date of the period, %4 = maximum requests';
    begin
        SampleRequestSetup.Get();
        if SampleRequestSetup."Max. Requests per Period" = 0 then
            exit;
        SampleRequestSetup.TestField("Request Period");

        StartPeriod := CalcDate(SampleRequestSetup."Request Period", WorkDate());

        OtherRequest.SetRange("Customer No.", SampleRequest."Customer No.");
        OtherRequest.SetRange("Request Date", StartPeriod, WorkDate());
        OtherRequest.SetFilter(Status, '<>%1&<>%2', OtherRequest.Status::Rejected, OtherRequest.Status::Cancelled);
        OtherRequest.SetFilter("No.", '<>%1', SampleRequest."No.");

        RequestCount := OtherRequest.Count();

        if RequestCount >= SampleRequestSetup."Max. Requests per Period" then
            Error(TooManyRequestsErr, SampleRequest."Customer No.", RequestCount, StartPeriod, SampleRequestSetup."Max. Requests per Period");
    end;

    procedure GetApprovalLimit(): Decimal
    var
        UserSetup: Record "User Setup";
    begin
        if UserSetup.Get(UserId()) then
            exit(UserSetup."Sample Approval Limit");
        exit(0);
    end;

    procedure CheckLimit(var SampleRequest: Record "Sample Request Header")
    var
        ApprovalLimit: Decimal;
        AboveLimitErr: Label 'The Total Amount is above limit';
    begin
        ApprovalLimit := GetApprovalLimit();
        SampleRequest.CalcFields("Total Amount");
        if SampleRequest."Total Amount" > ApprovalLimit then
            Error(AboveLimitErr);
    end;

    procedure CheckRequestOwnership(SampleRequest: Record "Sample Request Header")
    var
        OwnRequestErr: Label 'You cannot approve or reject your own sample request %1. Ask another user with a high enough approval limit.', Comment = '%1 = sample request no.';
    begin
        if SampleRequest."Requested By" = UserId() then
            Error(OwnRequestErr);
    end;

    procedure MarkAsShipped(var SampleRequest: Record "Sample Request Header")
    var
        NotApprovedErr: Label 'Only approved requests can be shipped. Sample request %1 has status %2. Submit and approve it first.', Comment = '%1 = sample request no., %2 = current status';
    begin
        if SampleRequest.Status <> SampleRequest.Status::Approved then
            Error(NotApprovedErr);
        SampleRequest.TestField("Tracking No.");

        SampleRequest."Shipped Date" := WorkDate();
        SetStatus(SampleRequest, SampleRequest.Status::Shipped);
    end;

    procedure ReopenRequest(var SampleRequest: Record "Sample Request Header")
    var
        CannotReopenErr: Label 'Only Pending Approval, Approved and Rejected requests can be reopened. Sample request %1 has status %2.', Comment = '%1 = sample request no., %2 = current status';
    begin
        if not (SampleRequest.Status in [SampleRequest.Status::"Pending Approval",
                                        SampleRequest.Status::Approved,
                                        SampleRequest.Status::Rejected]) then
            Error(CannotReopenErr, SampleRequest."No.", SampleRequest.Status);

        SampleRequest."Approved By" := '';
        SampleRequest."Approved Date" := 0D;
        SetStatus(SampleRequest, SampleRequest.Status::Open);
    end;

    procedure Reject(var SampleRequest: Record "Sample Request Header")
    begin
        CheckStatusPendingApproval(SampleRequest);
        CheckRequestOwnership(SampleRequest);
        CheckLimit(SampleRequest);
        SampleRequest.TestField("Rejection Reason");
        SetStatus(SampleRequest, SampleRequest.Status::Rejected);
    end;

    procedure CheckOpenRequest(var SampleRequest: Record "Sample Request Header")
    var
        NotOpenRequestErr: Label 'Sample request can be changed only if status is Open';
    begin
        if SampleRequest.Status <> SampleRequest.Status::Open then
            Error(NotOpenRequestErr);

    end;

    procedure Cancel(var SampleRequest: Record "Sample Request Header")
    var
        CancelQst: Label 'Do you want to cancel sample request %1?', Comment = '%1 = request no.';
        CannotCancelErr: Label 'Only Open, Pending Approval and Approved requests can be cancelled. Sample request %1 has status %2.', Comment = '%1 = sample request no., %2 = current status';
    begin
        if not (SampleRequest.Status in [SampleRequest.Status::Open,
                                        SampleRequest.Status::"Pending Approval",
                                        SampleRequest.Status::Approved]) then
            Error(CannotCancelErr, SampleRequest."No.", SampleRequest.Status);

        if GuiAllowed() then
            if not Confirm(CancelQst, false, SampleRequest."No.") then
                exit;

        SetStatus(SampleRequest, SampleRequest.Status::Cancelled);
    end;

    procedure Submit(var SampleRequest: Record "Sample Request Header")
    begin
        CheckOpenRequest(SampleRequest);
        SampleRequest.TestField("Customer No.");
        CheckNotBlockedCustomer(SampleRequest."Customer No.");
        CheckLines(SampleRequest);
        CheckMaxRequestsPerPeriod(SampleRequest);

        SampleRequest.CalcFields("Total Amount");
        if SampleRequest."Total Amount" <= GetApprovalLimit() then begin
            SampleRequest."Approved By" := CopyStr(UserId(), 1, MaxStrLen(SampleRequest."Approved By"));
            SampleRequest."Approved Date" := WorkDate();
            SetStatus(SampleRequest, SampleRequest.Status::Approved);
        end else
            SetStatus(SampleRequest, SampleRequest.Status::"Pending Approval");
    end;

    procedure Approve(var SampleRequest: Record "Sample Request Header")
    begin
        CheckStatusPendingApproval(SampleRequest);
        CheckRequestOwnership(SampleRequest);
        CheckLimit(SampleRequest);

        SampleRequest."Approved By" := CopyStr(UserId(), 1, MaxStrLen(SampleRequest."Approved By"));
        SampleRequest."Approved Date" := WorkDate();
        SetStatus(SampleRequest, SampleRequest.Status::Approved);
    end;

    procedure CheckStatusPendingApproval(SampleRequest: Record "Sample Request Header")
    var
        NotPendingApprovalErr: Label 'Only requests with status Pending Approval can be approved or rejected. Sample request %1 has status %2.', Comment = '%1 = sample request no., %2 = current status';
    begin
        if SampleRequest.Status <> SampleRequest.Status::"Pending Approval" then
            Error(NotPendingApprovalErr, SampleRequest.Status);
    end;

    procedure DeleteRequest(var SampleRequest: Record "Sample Request Header")
    var
        CannotDeleteErr: Label 'Only Open or Cancelled requests can be deleted. Sample request %1 has status %2. Cancel it first.', Comment = '%1 = sample request no., %2 = current status';
    begin
        if not (SampleRequest.Status in [SampleRequest.Status::Open,
                                        SampleRequest.Status::Cancelled]) then
            Error(CannotDeleteErr, SampleRequest."No.", SampleRequest.Status);
    end;

    local procedure SetStatus(var SampleRequest: Record "Sample Request Header"; NewStatus: Enum "Sample Request Status")
    var
        OldStatus: Enum "Sample Request Status";
    begin
        OldStatus := SampleRequest.Status;
        SampleRequest.Status := NewStatus;
        SampleRequest.Modify(true);
        OnAfterStatusChanged(SampleRequest, OldStatus, NewStatus);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterStatusChanged(var SampleRequest: Record "Sample Request Header"; OldStatus: Enum "Sample Request Status"; NewStatus: Enum "Sample Request Status")
    begin
    end;

    [EventSubscriber(ObjectType::Table, Database::Customer, 'OnBeforeDeleteEvent', '', false, false)]
    local procedure OnBeforeDeleteCustomer(var Rec: Record Customer; RunTrigger: Boolean)
    var
        SampleRequest: Record "Sample Request Header";
        CustomerOnRequestErr: Label 'You cannot delete customer %1 because it is on sample request %2. Cancel or finish that request first.', Comment = '%1 = customer no., %2 = sample request no.';
    begin
        if Rec.IsTemporary() then
            exit;

        SampleRequest.SetRange("Customer No.", Rec."No.");
        SampleRequest.SetFilter(Status, '%1|%2|%3',
            SampleRequest.Status::Open,
            SampleRequest.Status::"Pending Approval",
            SampleRequest.Status::Approved);
        if SampleRequest.FindFirst() then
            Error(CustomerOnRequestErr, Rec."No.", SampleRequest."No.");
    end;

    [EventSubscriber(ObjectType::Table, Database::Item, 'OnBeforeDeleteEvent', '', false, false)]
    local procedure OnBeforeDeleteItem(var Rec: Record Item; RunTrigger: Boolean)
    var
        SampleRequestLine: Record "Sample Request Line";
        SampleRequest: Record "Sample Request Header";
        ItemOnRequestErr: Label 'You cannot delete item %1 because it is on sample request %2. Cancel or finish that request first.', Comment = '%1 = item no., %2 = sample request no.';
    begin
        if Rec.IsTemporary() then
            exit;

        SampleRequestLine.SetRange("Item No.", Rec."No.");
        if SampleRequestLine.FindSet() then
            repeat
                SampleRequest.Get(SampleRequestLine."Document No.");
                if SampleRequest.Status in [SampleRequest.Status::Open,
                                            SampleRequest.Status::"Pending Approval",
                                            SampleRequest.Status::Approved] then
                    Error(ItemOnRequestErr, Rec."No.", SampleRequest."No.");
            until SampleRequestLine.Next() = 0;
    end;

    procedure CreateRequestForCustomer(CustomerNo: Code[20])
    var
        SampleRequestHeader: Record "Sample Request Header";
    begin
        SampleRequestHeader.Init();
        SampleRequestHeader.Insert(true);
        SampleRequestHeader.Validate("Customer No.", CustomerNo);
        SampleRequestHeader.Modify(true);
        Page.Run(Page::"Sample Requests Card", SampleRequestHeader);
    end;
}