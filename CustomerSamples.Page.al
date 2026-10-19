page 50107 "Customer Samples"
{
    PageType = CardPart;
    SourceTable = Customer;
    Caption = 'Customer Samples';

    layout
    {
        area(Content)
        {
            group(Samples)
            {
                field("Open Sample Requests"; Rec."Open Sample Requests")
                {
                    ApplicationArea = All;
                    Caption = 'Open Sample Requests';
                    ToolTip = 'Specifies the number of open sample requests for the customer.';
                }
                field("Shipped Sample Requests"; Rec."Shipped Sample Requests")
                {
                    ApplicationArea = All;
                    Caption = 'Shipped Sample Requests';
                    ToolTip = 'Specifies the number of shipped sample requests for the customer.';
                }
            }
        }
    }


}