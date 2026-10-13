table 50100 "Sample Request Header"
{
    DataClassification = CustomerContent;

    fields
    {
        field(1; "No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'No.';
        }
        field(2; "Customer No."; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = Customer;
            Caption = 'Customer No.';

            trigger OnValidate()
            var
                CustomerRec: Record Customer;
                Text001: Label 'Customer is blocked with status %1.';
            begin
                if "Customer No." = '' then begin
                    "Customer Name" := '';
                    exit;
                end;
                CustomerRec.Get("Customer No.");
                if CustomerRec.Blocked <> CustomerRec.Blocked::" " then
                    Error(Text001, CustomerRec.Blocked);
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
            begin
                if "Contact Email" <> '' then
                    exit;
                MailMngt.ValidateEmailAddressField("Contact Email");
            end;
        }
        field(5; Project; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Project';
        }
        field(6; "Request Date"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Request Date';
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
        field(13; "Shipping Date"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Shipping Date';
            Editable = false;
        }
        field(14; "No. Series"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'No. Series';
            TableRelation = "No. Series";
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

    fieldgroups
    {
        // Add changes to field groups here
    }

    var
        myInt: Integer;

    trigger OnInsert()
    var
        SampleRequestStatus: Enum "Sample Request Status";
    begin
        "Request Date" := WorkDate();
        "Requested By" := UserId();

    end;


    trigger OnModify()
    begin

    end;

    trigger OnDelete()
    begin

    end;

    trigger OnRename()
    begin

    end;

}