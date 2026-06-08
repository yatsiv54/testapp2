$files = Get-ChildItem -Path lib -Filter *.dart -Recurse

foreach ($file in $files) {
    $content = Get-Content $file.FullName -Raw
    $original = $content
    
    # withOpacity( -> withValues(alpha: 
    $content = $content -replace '\.withOpacity\(', '.withValues(alpha: '
    
    # activeColor: -> activeThumbColor:
    $content = $content -replace 'activeColor:', 'activeThumbColor:'
    
    # MaterialStateProperty -> WidgetStateProperty
    $content = $content -replace 'MaterialStateProperty', 'WidgetStateProperty'
    
    # Share.share -> SharePlus.instance.share (Wait, maybe we don't have SharePlus instance, let's just do Share.share. Actually, share_plus deprecated Share)
    # Actually let's just do this manually if there's only one.
    
    # Double underscores
    $content = $content -replace 'get__', 'get_'
    $content = $content -replace 'set__', 'set_'
    $content = $content -replace '___', '__'
    $content = $content -replace '  __', '  _'
    
    if ($content -ne $original) {
        Set-Content -Path $file.FullName -Value $content -NoNewline
        Write-Host "Updated $($file.Name)"
    }
}
