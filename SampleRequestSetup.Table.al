table 50103 "Sample Request Setup"
{
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {

        }
        field(2; "Sample Request Nos."; Code[20])
        {
            Caption = 'Sample Request Nos.';
            TableRelation = "No. Series";
        }
        field(3; "Default Max. Sample Qty."; Decimal)
        {
            Caption = 'Default Max. Sample Qty.';
            DecimalPlaces = 0 : 5;
            MinValue = 0;
        }
        field(4; "Max. Requests per Period"; Integer)
        {
            Caption = 'Max. Requests per Period';
            MinValue = 0;
        }
        field(5; "Request Period"; DateFormula)
        {
            Caption = 'Request Period';
        }

    }

    keys
    {
        key(Pk; "Primary Key")
        {
            Clustered = true;
        }
    }


    trigger OnInsert()
    begin
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