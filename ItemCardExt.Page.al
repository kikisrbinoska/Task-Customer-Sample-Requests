pageextension 50108 "Item Card Extension" extends "Item Card"
{
    layout
    {
        addafter(Item)
        {
            group(Samples)
            {
                Caption = 'Samples';
                field("Sample Allowed"; Rec."Sample Allowed")
                {
                    ApplicationArea = All;
                    Caption = 'Sample Allowed';
                    ToolTip = 'Specifies whether the item is allowed to be requested as a sample.';
                }
                field("Max. Sample Qty."; Rec."Max. Sample Qty.")
                {
                    ApplicationArea = All;
                    Caption = 'Max. Sample Qty.';
                    ToolTip = 'Specifies the maximum quantity that can be requested as a sample. 0 means the default from Sample Request Setup is used.';
                }
            }
        }
    }


}