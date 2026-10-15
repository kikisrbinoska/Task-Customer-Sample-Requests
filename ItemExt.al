tableextension 50102 "Item Extension" extends Item
{
    fields
    {
        field(50100; "Sample Allowed"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Sample Allowed';
        }
        field(50101; "Max. Sample Qty."; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Max. Sample Qty.';
            DecimalPlaces = 0 : 5;
            MinValue = 0;
        }
    }

}