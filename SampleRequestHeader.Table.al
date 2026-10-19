table 50100 "Sample Request Header"
{
    DataClassification = CustomerContent;
    DrillDownPageId = "Sample Requests List";
    LookupPageId = "Sample Requests List";

    fields
    {
        field(1; "No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'No.';

            trigger OnValidate()
            var
                SampleRequestSetup: Record "Sample Request Setup";
                NoSeries: Codeunit "No. Series";
            begin
                if "No." <> xRec."No." then begin
                    SampleRequestSetup.Get();
                    NoSeries.TestManual(SampleRequestSetup."Sample Request Nos.");
                    "No. Series" := '';
                end;
            end;
        }
        field(2; "Customer No."; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = Customer;
            Caption = 'Customer No.';

            trigger OnValidate()
            var
                CustomerRec: Record Customer;
                SampleRequestMgt: Codeunit "Sample Request Mgt.";
            begin
                SampleRequestMgt.CheckOpenRequest(Rec);
                if "Customer No." <> xRec."Customer No." then
                    SampleRequestMgt.CheckNoLinesExist(Rec);

                if "Customer No." = '' then begin
                    "Customer Name" := '';
                    exit;
                end;

                SampleRequestMgt.CheckNotBlockedCustomer("Customer No.");

                CustomerRec.Get("Customer No.");
                "Customer Name" := CustomerRec.Name;
            end;
        }
        field(3; "Customer Name"; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Customer Name';
            Editable = false;
        }
        field(4; "Contact Email"; Text[80])
        {
            DataClassification = CustomerContent;
            Caption = 'Contact Email';
            ExtendedDatatype = Email;

            trigger OnValidate()
            var
                MailMngt: Codeunit "Mail Management";
                SampleRequestMgt: Codeunit "Sample Request Mgt.";
            begin
                SampleRequestMgt.CheckOpenRequest(Rec);
                if "Contact Email" = '' then
                    exit;
                MailMngt.ValidateEmailAddressField("Contact Email");
            end;
        }
        field(5; Project; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Project';

            trigger OnValidate()
            var
                SampleRequestMgt: Codeunit "Sample Request Mgt.";
            begin
                SampleRequestMgt.CheckOpenRequest(Rec);
            end;
        }
        field(6; "Request Date"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Request Date';

            trigger OnValidate()
            var
                SampleRequestMgt: Codeunit "Sample Request Mgt.";
            begin
                SampleRequestMgt.CheckOpenRequest(Rec);
            end;
        }
        field(7; "Status"; Enum "Sample Request Status")
        {
            DataClassification = CustomerContent;
            Caption = 'Status';
            Editable = false;
        }
        field(8; "Requested By"; Code[50])
        {
            DataClassification = EnduserIdentifiableInformation;
            Caption = 'Requested By';
            Editable = false;
        }
        field(9; "Approved By"; Code[50])
        {
            DataClassification = EnduserIdentifiableInformation;
            Caption = 'Approved By';
            TableRelation = User."User Name";
            ValidateTableRelation = false;
            Editable = false;
        }
        field(10; "Approved Date"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Approved Date';
            Editable = false;
        }
        field(11; "Rejection Reason"; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = 'Rejection Reason';
        }
        field(12; "Tracking No."; Text[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Tracking No.';
        }
        field(13; "Shipped Date"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Shipped Date';
            Editable = false;
        }
        field(14; "No. Series"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'No. Series';
            TableRelation = "No. Series";
            Editable = false;
        }
        field(15; "Total Amount"; Decimal)
        {
            Caption = 'Total Amount';
            FieldClass = FlowField;
            CalcFormula = Sum("Sample Request Line"."Line Amount" where("Document No." = field("No.")));
            Editable = false;
        }

    }

    keys
    {
        key(Pk; "No.")
        {
            Clustered = true;
        }
    }
    procedure AssistEdit(OldSampleRequest: Record "Sample Request Header"): Boolean
    var
        SampleRequest: Record "Sample Request Header";
        SampleRequestSetup: Record "Sample Request Setup";
        NoSeries: Codeunit "No. Series";
    begin
        SampleRequest := Rec;
        SampleRequestSetup.Get();
        SampleRequestSetup.TestField("Sample Request Nos.");
        if NoSeries.LookupRelatedNoSeries(SampleRequestSetup."Sample Request Nos.", OldSampleRequest."No. Series", SampleRequest."No. Series") then begin
            SampleRequest."No." := NoSeries.GetNextNo(SampleRequest."No. Series");
            Rec := SampleRequest;
            exit(true);
        end;
    end;

    trigger OnInsert()
    var
        SampleRequestSetup: Record "Sample Request Setup";
        NoSeries: Codeunit "No. Series";
    begin
        if "No." = '' then begin
            SampleRequestSetup.Get();
            SAmpleRequestSetup.TestField("Sample Request Nos.");
            "No. Series" := SampleRequestSetup."Sample Request Nos.";
            "No." := NoSeries.GetNextNo("No. Series");
        end;

        "Request Date" := WorkDate();
        "Requested By" := CopyStr(UserId(), 1, MaxStrLen("Requested By"));
    end;


    trigger OnModify()
    begin

    end;

    trigger OnDelete()
    var
        SampleRequestMgt: Codeunit "Sample Request Mgt.";
        SampleRequestLine: Record "Sample Request Line";
    begin
        SampleRequestMgt.DeleteRequest(Rec);
        SampleRequestLine.SetRange("Document No.", "No.");
        SampleRequestLine.DeleteAll(true);
    end;

    trigger OnRename()
    begin

    end;

}