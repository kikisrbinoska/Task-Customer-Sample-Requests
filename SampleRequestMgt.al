codeunit 50100 "Sample Request Mgt."
{
    trigger OnRun()
    begin

    end;

    procedure CheckNotBlockedCustomer(CustomerNo: Code[20])
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

    // R5
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

        StartPeriod := CalcDate(SampleRequestSetup."Request Period", WorkDate());

        OtherRequest.SetRange("Customer No.", SampleRequest."Customer No.");
        OtherRequest.SetRange("Request Date", StartPeriod, WorkDate());
        OtherRequest.SetFilter(Status, '<>%1&<>%2', OtherRequest.Status::Rejected, OtherRequest.Status::Canelled);
        OtherRequest.SetFilter("No.", '<>%1', SampleRequest."No.");

        RequestCount := OtherRequest.Count();

        if RequestCount >= SampleRequestSetup."Max. Requests per Period" then
            Error(TooManyRequestsErr, SampleRequest."Customer No.", RequestCount, StartPeriod, SampleRequestSetup."Max. Requests per Period");
    end;


    procedure Submit(var SampleRequest: Record "Sample Request Header")
    begin
        SampleRequest.TestField(Status, SampleRequest.Status);
        SampleRequest.TestField("Customer No.");
        CheckNotBlockedCustomer(SampleRequest."Customer No.");
        CheckLines(SampleRequest);
        CheckMaxRequestsPerPeriod(SampleRequest);
    end;
}