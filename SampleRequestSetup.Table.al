table 50103 "Sample Request Setup"
{
    DataClassification = CustomerContent;
    Caption = 'Sample Request Setup';

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
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

            trigger OnValidate()
            var
                PeriodMustBeNegativeErr: Label 'Request Period must look back in time, e.g. -30D.';
            begin
                if CalcDate("Request Period", WorkDate()) > WorkDate() then
                    Error(PeriodMustBeNegativeErr);

            end;
        }

    }

    keys
    {
        key(Pk; "Primary Key")
        {
            Clustered = true;
        }
    }

    procedure InsertIfNotExist()
    begin
        Reset();
        if not Get() then begin
            Init();
            Insert();
        end;
    end;




}