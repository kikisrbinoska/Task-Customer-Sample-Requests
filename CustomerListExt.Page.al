pageextension 50111 "Customer List Extension" extends "Customer List"
{
    layout
    {
        addfirst(FactBoxes)
        {
            part(CustomerSamples; "Customer Samples")
            {
                ApplicationArea = All;
                SubPageLink = "No." = field("No.");
            }
        }
    }
    actions
    {
        addlast(Processing)
        {
            action("SampleRequests")
            {
                ApplicationArea = All;
                Caption = 'Sample Requests';
                ToolTip = 'View the sample requests for this customer.';
                Image = Documents;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "Sample Requests List";
                RunPageLink = "Customer No." = field("No.");
            }
            action("NewSampleRequest")
            {
                ApplicationArea = All;
                Caption = 'New Sample Request';
                ToolTip = 'Create a new sample request for this customer';
                Image = NewDocument;

                trigger OnAction()
                var
                    SampleRequestMgt: Codeunit "Sample Request Mgt.";
                begin
                    SampleRequestMgt.CreateRequestForCustomer(Rec."No.");
                end;
            }
        }
    }
}