Add-Type -AssemblyName System.Drawing

$renderDir = Join-Path (Split-Path $PSScriptRoot -Parent) "renders"

function New-M2ContactSheet {
    param(
        [string]$OutputName,
        [array]$Items
    )

    $cellWidth = 720
    $cellHeight = 770
    $bitmap = [System.Drawing.Bitmap]::new(1440, 1540)
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    $graphics.Clear([System.Drawing.Color]::FromArgb(8, 10, 14))
    $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $font = [System.Drawing.Font]::new("Segoe UI", 24, [System.Drawing.FontStyle]::Bold)
    $brush = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(230, 232, 238))

    try {
        for ($index = 0; $index -lt $Items.Count; $index++) {
            $column = $index % 2
            $row = [Math]::Floor($index / 2)
            $x = $column * $cellWidth
            $y = $row * $cellHeight
            $source = Join-Path $renderDir $Items[$index].File
            $image = [System.Drawing.Image]::FromFile($source)
            try {
                $scale = [Math]::Min(720.0 / $image.Width, 720.0 / $image.Height)
                $width = [int]($image.Width * $scale)
                $height = [int]($image.Height * $scale)
                $drawX = $x + [int]((720 - $width) / 2)
                $drawY = $y + [int]((720 - $height) / 2)
                $graphics.DrawImage($image, $drawX, $drawY, $width, $height)
            }
            finally {
                $image.Dispose()
            }
            $graphics.DrawString($Items[$index].Label, $font, $brush, $x + 18, $y + 724)
        }

        $bitmap.Save((Join-Path $renderDir $OutputName), [System.Drawing.Imaging.ImageFormat]::Png)
    }
    finally {
        $brush.Dispose()
        $font.Dispose()
        $graphics.Dispose()
        $bitmap.Dispose()
    }
}

New-M2ContactSheet -OutputName "M2_orthographic_contact_sheet.png" -Items @(
    @{ File = "M2_01_front.png"; Label = "VISTA FRONTAL" },
    @{ File = "M2_02_side.png"; Label = "VISTA LATERAL" },
    @{ File = "M2_03_back.png"; Label = "VISTA TRASEIRA" },
    @{ File = "M2_04_three_quarter.png"; Label = "VISTA 3/4" }
)

New-M2ContactSheet -OutputName "M2_validation_contact_sheet.png" -Items @(
    @{ File = "M2_05_silhouette.png"; Label = "SILHUETA" },
    @{ File = "M2_06_hands_close.png"; Label = "CLOSE DAS MAOS" },
    @{ File = "M2_07_r6_comparison.png"; Label = "COMPARACAO R6" },
    @{ File = "M2_08_dark_test.png"; Label = "TESTE ESCURO" }
)
