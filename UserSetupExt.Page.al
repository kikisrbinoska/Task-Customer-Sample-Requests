pageextension 50109 "User Setup Extension" extends "User Setup"
{
    layout
    {
        addlast(Control1)
        {
            field("Sample Approval Limit"; Rec."Sample Approval Limit")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the maximum total amount of a sample request that the user can approve.';
            }
        }
    }

}