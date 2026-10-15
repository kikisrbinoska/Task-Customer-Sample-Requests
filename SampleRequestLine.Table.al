table 50101 "Sample Request Line"
{
    DataClassification = CustomerContent;
    Caption = 'Sample Request Line';

    fields
    {
        field(1; "Document No."; Code[20])
        {
            TableRelation = "Sample Request Header"."No.";
            Caption = 'Document No.';
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(3; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            TableRelation = Item where("Sample Allowed" = const(true), Blocked = const(false));

            trigger OnValidate()
            var
                ItemRec: Record Item;
            begin
                if "Item No." = '' then begin
                    Description := '';
                    "Unit of Measure Code" := '';
                    "Unit Price" := 0;
                    exit;
                end;
                ItemRec.Get("Item No.");
                ItemRec.TestField(Blocked, false);
                if not ItemRec."Sample Allowed" then
                    Error('Item %1 is not allowed for sample requests.', "Item No.");
                Description := ItemRec.Description;
                "Unit of Measure Code" := ItemRec."Base Unit of Measure";
                "Unit Price" := ItemRec."Unit Price";
                if Quantity <> 0 then
                    Validate(Quantity)
                else
                    UpdateLineAmount();
            end;
        }
        field(4; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(5; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code';
            TableRelation = "Item Unit of Measure".Code where("Item No." = field("Item No."));
            Editable = false;
        }
        field(6; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DecimalPlaces = 0 : 5;

            trigger OnValidate()
            var
                MaxQty: Decimal;
                QtyMustBePositiveErr: Label 'Quantity must be greater than 0.';
                QtyExceedsMaxErr: Label 'Quantity cannot be more than %1 for item %2.', Comment = '%1 = maximum quantity, %2 = item no.';
            begin
                if Quantity <= 0 then
                    Error(QtyMustBePositiveErr);

                if "Item No." <> '' then begin
                    MaxQty := GetMaxSampleQty();
                    if (MaxQty > 0) and (Quantity > MaxQty) then
                        Error(QtyExceedsMaxErr, MaxQty, "Item No.");
                end;

                UpdateLineAmount();
            end;
        }
        field(7; "Unit Price"; Decimal)
        {
            Caption = 'Unit Price';
            AutoFormatType = 2;
            Editable = false;
        }
        field(8; "Line Amount"; Decimal)
        {
            Caption = 'Line Amount';
            AutoFormatType = 2;
            Editable = false;
        }


    }
    keys
    {
        key(Pk; "Document No.", "Line No.")
        {
            Clustered = true;
        }
    }
    local procedure UpdateLineAmount()
    begin
        "Line Amount" := Round(Quantity * "Unit Price");
    end;

    local procedure GetMaxSampleQty(): Decimal
    var
        ItemRec: Record Item;
        SampleRequestSetup: Record "Sample Request Setup";
    begin
        ItemRec.Get("Item No.");
        if ItemRec."Max. Sample Qty." <> 0 then
            exit(ItemRec."Max. Sample Qty.");
        SampleRequestSetup.Get();
        exit(SampleRequestSetup."Default Max. Sample Qty.");
    end;




}