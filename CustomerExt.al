tableextension 50105 "Customer Extension" extends Customer
{
    fields
    {
        field(50101; "Open Sample Requests"; Integer)
        {
            Caption = 'Open Sample Requests';
            FieldClass = FlowField;
            CalcFormula = count("Sample Request Header" where("Customer No." = field("No."), Status = filter(Open | "Pending Approval" | Approved)));
            Editable = false;
        }
        field(50102; "Shipped Sample Requests"; Integer)
        {
            Caption = 'Shipped Sample Requests';
            FieldClass = FlowField;
            CalcFormula = count("Sample Request Header" where("Customer No." = field("No."), Status = filter(Shipped)));
            Editable = false;
        }
    }

}