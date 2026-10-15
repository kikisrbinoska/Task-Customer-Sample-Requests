tableextension 50104 "User Setup Extension" extends "User Setup"
{
    fields
    {
        field(50101; "Sample Approval Limit"; Decimal)
        {
            Caption = 'Sample Approval Limit';
            DataClassification = CustomerContent;
            AutoFormatType = 1;
            MinValue = 0;
        }
    }

}