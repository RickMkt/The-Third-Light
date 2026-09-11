Add-Type -AssemblyName System.Drawing

$renderDir = Join-Path (Split-Path $PSScriptRoot -Parent) "renders"

function New-ContactSheet {
    param(
        [string]$OutputName,
        [array]$Items,
        [int]$Columns = 2
    )

    $cellWidth = 720
    $cellHeight = 770
    $rows = [Math]::Ceiling($Items.Count / $Columns)
    $bitmap = [System.Drawing.Bitmap]::new($cellWidth * $Columns, $cellHeight * $rows)
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    $graphics.Clear([System.Drawing.Color]::FromArgb(10, 12, 16))
    $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $font = [System.Drawing.Font]::new("Segoe UI", 24, [System.Drawing.FontStyle]::Bold)
    $brush = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(225, 228, 234))

    try {
        for ($index = 0; $index -lt $Items.Count; $index++) {
            $column = $index % $Columns
            $row = [Math]::Floor($index / $Columns)
            $x = $column * $cellWidth
            $y = $row * $cellHeight
            $source = Join-Path $renderDir $Items[$index].File
            $image = [System.Drawing.Image]::FromFile($source)
            try {
                $graphics.DrawImage($image, $x, $y, 720, 720)
            }
            finally {
                $image.Dispose()
            }
            $graphics.DrawString($Items[$index].Label, $font, $brush, $x + 18, $y + 724)
        }

        $outputPath = Join-Path $renderDir $OutputName
        $bitmap.Save($outputPath, [System.Drawing.Imaging.ImageFormat]::Png)
    }
    finally {
        $brush.Dispose()
        $font.Dispose()
        $graphics.Dispose()
        $bitmap.Dispose()
    }
}

New-ContactSheet -OutputName "M1_orthographic_contact_sheet.png" -Items @(
    @{ File = "01_front.png"; Label = "VISTA FRONTAL" },
    @{ File = "02_side.png"; Label = "VISTA LATERAL" },
    @{ File = "03_back.png"; Label = "VISTA TRASEIRA" },
    @{ File = "04_three_quarter.png"; Label = "VISTA 3/4" }
)

New-ContactSheet -OutputName "M1_scale_silhouette_contact_sheet.png" -Items @(
    @{ File = "05_r6_comparison.png"; Label = "COMPARACAO R6" },
    @{ File = "06_black_silhouette.png"; Label = "SILHUETA PRETA" }
)

New-ContactSheet -OutputName "M1_environment_contact_sheet.png" -Items @(
    @{ File = "07_between_trees_dark.png"; Label = "ENTRE ARVORES / ESCURO" },
    @{ File = "08_behind_rock.png"; Label = "ATRAS DA ROCHA" },
    @{ File = "09_corridor_dark.png"; Label = "FINAL DO CORREDOR" },
    @{ File = "10_flashlight_test.png"; Label = "TESTE DE LANTERNA" }
)
