codeunit 50100 "Sample Request Mgt."
{
    trigger OnRun()
    begin

    end;

    procedure CheckNotBlockedCustomer(CustomerNo: Code[20])//need
    var
        Customer: Record Customer;
    begin
        Customer.Get(CustomerNo);
        if Customer.Blocked <> Customer.Blocked::" " then
            Error('Customer %1 is blocked with status %2.', CustomerNo, Customer.Blocked);
    end;

    procedure CheckItemAllowed(ItemNo: Code[20])
    var
        Item: Record Item;
    begin
        Item.Get(ItemNo);
        Item.TestField(Blocked, false);
        if not Item."Sample Allowed" then
            Error('Item %1 is not allowed', ItemNo);
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
    begin
        if Quantity <= 0 then
            Error('Quantity need to be grater than 0');
        MaxQuantity := GetMaxSampleQuantity(ItemNo);
        if (MaxQuantity > 0) and (Quantity > MaxQuantity) then
            Error('Quantity can not be more than %1 for %2', MaxQuantity, ItemNo);

    end;

    procedure CheckLines(var SampleRequest: Record "Sample Request Header")
    var
        SampleRequestLine: Record "Sample Request Line";
    begin
        SampleRequestLine.SetRange("Document No.", SampleRequest."No.");
        if SampleRequestLine.IsEmpty() then
            Error('Sample request %1 has no lines and can not be submited', SampleRequest."No.");
    end;

    procedure CheckNoLinesExist(var SampleRequest: Record "Sample Request Header")
    var
        SampleRequestLine: Record "Sample Request Line";
    begin
        SampleRequestLine.SetRange("Document No.", SampleRequest."No.");
        if not SampleRequestLine.IsEmpty() then
            Error('Sample request already has lines');
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
        OtherRequest.SetFilter(Status, '<>%1&<>%2', OtherRequest.Status::Rejected, OtherRequest.Status::Canelled);
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

    procedure CheckApprovalLevel(var SampleRequest: Record "Sample Request Header")
    begin
        if SampleRequest.Status <> SampleRequest.Status::"Pending Approval" then
            Error('Only requests with status Pending Approval can be approved or rejected. The current status is %1.', SampleRequest.Status);
    end;

    procedure CheckLimit(var SampleRequest: Record "Sample Request Header")
    var
        ApprovalLimit: Decimal;
    begin
        ApprovalLimit := GetApprovalLimit();
        SampleRequest.CalcFields("Total Amount");
        if SampleRequest."Total Amount" > ApprovalLimit then
            Error('Above limit');
    end;

    procedure CheckRequestOwnership(SampleRequest: Record "Sample Request Header")
    begin
        if SampleRequest."Requested By" = UserId() then
            Error('You cannot approve your own sample request');
    end;

    procedure MarkAsShipped(var SampleRequest: Record "Sample Request Header")
    begin
        if SampleRequest.Status <> SampleRequest.Status::Approved then
            Error('Request is not approved');
        SampleRequest.TestField("Tracking No.");

        SampleRequest."Shipped Date" := WorkDate();
        SetStatus(SampleRequest, SampleRequest.Status::Shipped);
    end;

    procedure ReopenRequest(var SampleRequest: Record "Sample Request Header")
    begin
        if not (SampleRequest.Status in [SampleRequest.Status::"Pending Approval",
                                         SampleRequest.Status::Approved,
                                         SampleRequest.Status::Rejected]) then
            Error('Only Pending Approval, Approved and Rejected requests can be reopened.');

        SampleRequest."Approved By" := '';
        SampleRequest."Approved Date" := 0D;
        SetStatus(SampleRequest, SampleRequest.Status::Open);
        SampleRequest.Modify(true);
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
    begin
        if SampleRequest.Status <> SampleRequest.Status::Open then
            Error('Sample request can be changed only if status is Open');

    end;

    procedure Cancel(var SampleRequest: Record "Sample Request Header")
    var
        CancelQst: Label 'Do you want to cancel sample request %1?', Comment = '%1 = request no.';
    begin
        if not (SampleRequest.Status in [SampleRequest.Status::Open,
                                        SampleRequest.Status::"Pending Approval",
                                        SampleRequest.Status::Approved]) then
            Error('Only open, pending or approved requests can be cancelled. The current status is %1.', SampleRequest.Status);

        if GuiAllowed() then
            if not Confirm(CancelQst, false, SampleRequest."No.") then
                exit;

        SetStatus(SampleRequest, SampleRequest.Status::Canelled);
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
    begin
        if SampleRequest.Status <> SampleRequest.Status::"Pending Approval" then
            Error('Only requests with status Pending Approval can be approved or rejected. The current status is %1.', SampleRequest.Status);
    end;

    procedure DeleteRequest(var SampleRequest: Record "Sample Request Header")
    begin
        if not (SampleRequest.Status in [SampleRequest.Status::Open,
                                        SampleRequest.Status::Canelled]) then
            Error('Only Open or Cancelled requests can be deleted');
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
    begin
        if Rec.IsTemporary() then
            exit;

        SampleRequest.SetRange("Customer No.", Rec."No.");
        SampleRequest.SetFilter(Status, '%1|%2|%3',
            SampleRequest.Status::Open,
            SampleRequest.Status::"Pending Approval",
            SampleRequest.Status::Approved);
        if SampleRequest.FindFirst() then
            Error('Customer %1 cannot be deleted because it is on sample request %2.', Rec."No.", SampleRequest."No.");
    end;

    [EventSubscriber(ObjectType::Table, Database::Item, 'OnBeforeDeleteEvent', '', false, false)]
    local procedure OnBeforeDeleteItem(var Rec: Record Item; RunTrigger: Boolean)
    var
        SampleRequestLine: Record "Sample Request Line";
        SampleRequest: Record "Sample Request Header";
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
                    Error('Item %1 cannot be deleted because it is on sample request %2.', Rec."No.", SampleRequest."No.");
            until SampleRequestLine.Next() = 0;
    end;
}