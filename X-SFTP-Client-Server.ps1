#############################################################################################################################################################################
# EXTENDED SFTP CLIENT-SERVER FOR WINDOWS
#############################################################################################################################################################################

# ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# FEATURES
# ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# • Encrypt password and config file
# • Decrypt config file and password
# • Create x509 Certificate
# • File Signature (via .pfx file - private key)
# • File Signature Verifier (via .cer file - public key) 
# • SFTP Client for file transfer: Uploads selected file(s) to the remote SSH server
# • SFTP Server for file transfer: Receives file(s) from the SFTP client over SSH
# ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# CONFIGURATION OF WIN FORM APP.
# ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# WPF assemblies
Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName WindowsBase
Add-Type -AssemblyName System.Xaml
# XAML UI
$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="X-SFTP Client-Server for Windows"
        Background="#4096"
        WindowStartupLocation="CenterScreen"
        SizeToContent="WidthAndHeight"
        MaxWidth="666"
        MaxHeight="1044">
    <Window.Resources>
        <!-- Neon Button Style -->
        <Style TargetType="Button">
            <Setter Property="Foreground" Value="#dfff00"/>
            <Setter Property="Background" Value="#001f5c"/>
            <Setter Property="BorderBrush" Value="#dfff00"/>
            <Setter Property="BorderThickness" Value="2"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="Height" Value="35"/>
            <Setter Property="FontSize" Value="14"/>
            <Setter Property="FontWeight" Value="Bold"/>
            <Setter Property="HorizontalContentAlignment" Value="Left"/>
            <Setter Property="VerticalContentAlignment" Value="Center"/>
            <Setter Property="Padding" Value="6,0,0,0"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border Background="{TemplateBinding Background}"
                                BorderBrush="{TemplateBinding BorderBrush}"
                                BorderThickness="{TemplateBinding BorderThickness}"
                                CornerRadius="6">
                                <ContentPresenter 
                                HorizontalAlignment="{TemplateBinding HorizontalContentAlignment}" 
                                VerticalAlignment="{TemplateBinding VerticalContentAlignment}"
                                Margin="{TemplateBinding Padding}"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <!-- Hover -->
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter Property="Background" Value="#dfff00"/>
                                <Setter Property="Foreground" Value="#00008b"/>
                                <Setter Property="BorderBrush" Value="#00008b"/>
                                <Setter Property="FontSize" Value="15"/>
                                <Setter Property="FontWeight" Value="Bold"/>
                                <Setter Property="BorderThickness" Value="3"/>
                                <Setter Property="Effect">
                                    <Setter.Value>
                                        <DropShadowEffect Color="#dfff00" BlurRadius="10" ShadowDepth="0" Opacity="1"/>
                                    </Setter.Value>
                                </Setter>
                            </Trigger>
                            <!-- Pressed -->
                            <Trigger Property="IsPressed" Value="True">
                                <Setter Property="Background" Value="#dfff00"/>
                                <Setter Property="Foreground" Value="#00008b"/>
                                <Setter Property="BorderBrush" Value="#00008b"/>
                                <Setter Property="BorderThickness" Value="4"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>
        <!-- Neon TextBox Style -->
        <Style TargetType="TextBox">
            <Setter Property="Foreground" Value="#dfff00"/>
            <Setter Property="Background" Value="#001f5c"/>
            <Setter Property="BorderBrush" Value="#dfff00"/>
            <Setter Property="BorderThickness" Value="2"/>
            <Setter Property="FontSize" Value="14"/>
            <Setter Property="Height" Value="35"/>
            <Setter Property="Padding" Value="6"/>
            <Setter Property="FontWeight" Value="Bold"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="TextBox">
                        <Border x:Name="border"
                                Background="{TemplateBinding Background}"
                                BorderBrush="{TemplateBinding BorderBrush}"
                                BorderThickness="{TemplateBinding BorderThickness}"
                                CornerRadius="6">
                            <ScrollViewer x:Name="PART_ContentHost"
                                        Margin="0"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <!-- Hover -->
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter TargetName="border" Property="BorderBrush" Value="#dfff00"/>
                                <Setter TargetName="border" Property="BorderThickness" Value="2"/>
                            </Trigger>
                            <Trigger Property="IsKeyboardFocused" Value="True">
                                <Setter TargetName="border" Property="BorderBrush" Value="#dfff00"/>
                                <Setter TargetName="border" Property="BorderThickness" Value="2"/>
                            </Trigger>
                            <!-- Disabled -->
                            <Trigger Property="IsEnabled" Value="False">
                                <Setter TargetName="border" Property="Opacity" Value="1"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>
        <!-- Neon PasswordBox Style -->
        <Style TargetType="PasswordBox">
            <Setter Property="Foreground" Value="#dfff00"/>
            <Setter Property="Background" Value="#001f5c"/>
            <Setter Property="BorderBrush" Value="#dfff00"/>
            <Setter Property="BorderThickness" Value="2"/>
            <Setter Property="FontSize" Value="14"/>
            <Setter Property="Height" Value="35"/>
            <Setter Property="Padding" Value="6"/>
            <Setter Property="CaretBrush" Value="#dfff00"/>
            <!-- Disable default blue focus visual -->
            <Setter Property="FocusVisualStyle" Value="{x:Null}"/>
            <!-- Custom template -->
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="PasswordBox">
                        <Border x:Name="border"
                                Background="{TemplateBinding Background}"
                                BorderBrush="{TemplateBinding BorderBrush}"
                                BorderThickness="{TemplateBinding BorderThickness}"
                                CornerRadius="6">
                            <ScrollViewer x:Name="PART_ContentHost" Margin="0"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <!-- Hover -->
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter TargetName="border" Property="BorderBrush" Value="#dfff00"/>
                                <Setter TargetName="border" Property="BorderThickness" Value="2"/>
                            </Trigger>
                            <!-- Focus (cursor inside) -->
                            <Trigger Property="IsKeyboardFocused" Value="True">
                                <Setter TargetName="border" Property="BorderBrush" Value="#dfff00"/>
                                <Setter TargetName="border" Property="BorderThickness" Value="2"/>
                            </Trigger>
                            <!-- Disabled -->
                            <Trigger Property="IsEnabled" Value="False">
                                <Setter TargetName="border" Property="Opacity" Value="0.6"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>           
        </Style>
    </Window.Resources>
<StackPanel Margin="10, 5, 10, 5" Orientation="Vertical">
    <!-- 🔑 Cryptography Tools Panel -->
    <Border Background="#333"
            CornerRadius="8"
            Padding="15"
            Margin="0,0,0,0"
            BorderBrush="#dfff00"
            BorderThickness="5">
        <Border.Effect>
            <DropShadowEffect x:Name="CryptoGlow"
                              Color="#ffff00"
                              BlurRadius="12"
                              ShadowDepth="0"
                              Opacity="0.9"/>
        </Border.Effect>
        <StackPanel Orientation="Vertical">
                        <TextBlock Text="🔑 Cryptography Tools"
                                   Foreground="#dfff00"
                                   FontSize="16"
                                   FontWeight="Bold"
                                   HorizontalAlignment="Right"
                                   Margin="0,0,0,0">
                            <TextBlock.Effect>
                                <DropShadowEffect Color="#ffff00"
                                                  BlurRadius="12"
                                                  ShadowDepth="0"
                                                  Opacity="1"/>
                            </TextBlock.Effect>
                        </TextBlock>
            <TextBlock Text="🔒 Enter password to encrypt:"
                       Foreground="#dfff00"
                       FontSize="11"
                         FontWeight="Bold"
                       Margin="0,0,0,-5">
                            <TextBlock.Effect>
                                <DropShadowEffect Color="#ffff00"
                                                  BlurRadius="12"
                                                  ShadowDepth="0"
                                                  Opacity="1"/>
                            </TextBlock.Effect>
             </TextBlock>          
            <PasswordBox Name="PasswordInput" Height="35" Margin="0,10,0,10"/>
            <Button Name="EncryptButton" Content="🔐 Encrypt password" Margin="0,10,0,10"/>
            <Button Name="DecryptButton" Content="🔓 Decrypt password" Margin="0,10,0,10"/>
            <Button Name="CreatePfxButton" Content="📜 Create PFX Certificate" Margin="0,10,0,10"/>
            <Button Name="SignButton" Content="✍️ Sign file with PFX" Margin="0,10,0,10"/>
            <Button Name="VerifyButton" Content="✅ Verify file + SIG + CER" Margin="0,10,0,10"/>
        </StackPanel>
        <!-- neon heads -->
        <Border.Triggers>
            <EventTrigger RoutedEvent="Loaded">
                <BeginStoryboard>
                    <Storyboard RepeatBehavior="Forever" AutoReverse="True">
                        <DoubleAnimation Storyboard.TargetName="CryptoGlow"
                                         Storyboard.TargetProperty="Opacity"
                                         From="0.6" To="1.0"
                                         Duration="0:0:1.5"/>
                    </Storyboard>
                </BeginStoryboard>
            </EventTrigger>
        </Border.Triggers>
    </Border>
    <!-- Margin between sections -->
    <Border Height="15" Background="Transparent"/>
    <!-- 📤 SSH Client -->
    <Border Background="#333"
            CornerRadius="8"
            Padding="15"
            Margin="0,0,0,0"
            BorderBrush="#dfff00"
            BorderThickness="5">
        <Border.Effect>
            <DropShadowEffect x:Name="SftpGlow"
                              Color="#ffff00"
                              BlurRadius="12"
                              ShadowDepth="0"
                              Opacity="0.9"/>
        </Border.Effect>
        <StackPanel Orientation="Vertical">
                        <TextBlock Text="📤 SSH Client"
                                   Foreground="#dfff00"
                                   FontSize="16"
                                   FontWeight="Bold"
                                   HorizontalAlignment="Right"
                                   Margin="0,0,0,0">
                            <TextBlock.Effect>
                                <DropShadowEffect Color="#ffff00"
                                                  BlurRadius="12"
                                                  ShadowDepth="0"
                                                  Opacity="1"/>
                            </TextBlock.Effect>
                        </TextBlock>           
            <TextBlock Text="SSH Server Address:"
                       Foreground="#dfff00"
                       FontSize="11"
                          FontWeight="Bold"
                       Margin="0,0,0,-10">
                            <TextBlock.Effect>
                                <DropShadowEffect Color="#ffff00"
                                                  BlurRadius="12"
                                                  ShadowDepth="0"
                                                  Opacity="1"/>
                            </TextBlock.Effect>
                        </TextBlock>                        
            <TextBox Name="HostInput" Text="127.0.0.1" Margin="0,10,0,0"/>
            <TextBlock Text="Server SSH Port:"
                       Foreground="#dfff00"
                       FontSize="11"
                          FontWeight="Bold"
                       Margin="0,10,0,-10">
                            <TextBlock.Effect>
                                <DropShadowEffect Color="#ffff00"
                                                  BlurRadius="12"
                                                  ShadowDepth="0"
                                                  Opacity="1"/>
                            </TextBlock.Effect>
                        </TextBlock>            
            <TextBox Name="PortInput" Text="2235" Margin="0,10,0,10"/>
            <TextBlock Text="Client Credential - Username:"
                       Foreground="#dfff00"
                       FontSize="11"
                          FontWeight="Bold"
                       Margin="0,0,0,-10">
                            <TextBlock.Effect>
                                <DropShadowEffect Color="#ffff00"
                                                  BlurRadius="12"
                                                  ShadowDepth="0"
                                                  Opacity="1"/>
                            </TextBlock.Effect>
                        </TextBlock>            
            <TextBox Name="UserInput" Text="" Margin="0,10,0,10"/>
            <TextBlock Text="Client Credential - Path to the SSH Private Key:"
                       Foreground="#dfff00"
                       FontSize="11"
                          FontWeight="Bold"
                       Margin="0,0,0,-10">
                            <TextBlock.Effect>
                                <DropShadowEffect Color="#ffff00"
                                                  BlurRadius="12"
                                                  ShadowDepth="0"
                                                  Opacity="1"/>
                            </TextBlock.Effect>
                        </TextBlock>            
            <TextBox Name="KeyInput" Text="C:\Users\$env:USERNAME\.ssh\client_ssh_private_key" Margin="0,10,0,0"/>
            <TextBlock Name="chrootLabel" Text="📂 SFTP Session Root Directory:"
                Foreground="#dfff00"
                FontSize="11"
                 FontWeight="Bold"
                Margin="0,10,0,0">
                    <TextBlock.Effect>
                        <DropShadowEffect Color="#ffff00"
                                            BlurRadius="12"
                                            ShadowDepth="0"
                                            Opacity="1"/>
                    </TextBlock.Effect>
            </TextBlock>
            <Button Name="UploadButton" Content="📤 Select, Upload, and Send File via SFTP" Margin="0,0,0,0">
                <Button.Style>
                    <Style TargetType="Button">
                        <!-- Initial state (was hover before) -->
                        <Setter Property="Foreground" Value="#00008b"/>
                        <Setter Property="Background" Value="#dfff00"/>
                        <Setter Property="BorderBrush" Value="#00008b"/>
                        <Setter Property="BorderThickness" Value="2"/>
                        <Setter Property="FontSize" Value="14"/>
                        <Setter Property="FontWeight" Value="Bold"/>
                        <Setter Property="Height" Value="35"/>
                        <Setter Property="Cursor" Value="Hand"/>
                        <Setter Property="HorizontalContentAlignment" Value="Left"/>
                        <Setter Property="VerticalContentAlignment" Value="Center"/>
                        <Setter Property="Padding" Value="6,0,0,0"/>
                        <Setter Property="Template">
                            <Setter.Value>
                                <ControlTemplate TargetType="Button">
                                    <Border Background="{TemplateBinding Background}"
                                            BorderBrush="{TemplateBinding BorderBrush}"
                                            BorderThickness="{TemplateBinding BorderThickness}"
                                            CornerRadius="6">
                                        <ContentPresenter HorizontalAlignment="{TemplateBinding HorizontalContentAlignment}" 
                                                        VerticalAlignment="{TemplateBinding VerticalContentAlignment}"
                                                        Margin="{TemplateBinding Padding}"/>
                                    </Border>
                                    <ControlTemplate.Triggers>
                                        <!-- Hover (revert to original initial style) -->
                                        <Trigger Property="IsMouseOver" Value="True">
                                            <Setter Property="Background" Value="#001f5c"/>
                                            <Setter Property="Foreground" Value="#dfff00"/>
                                            <Setter Property="BorderBrush" Value="#dfff00"/>
                                            <Setter Property="BorderThickness" Value="3"/>
                                        </Trigger>
                                        <!-- Pressed -->
                                        <Trigger Property="IsPressed" Value="True">
                                            <Setter Property="Background" Value="#001f5c"/>
                                            <Setter Property="Foreground" Value="#dfff00"/>
                                            <Setter Property="BorderBrush" Value="#dfff00"/>
                                            <Setter Property="BorderThickness" Value="4"/>
                                        </Trigger>
                                    </ControlTemplate.Triggers>
                                </ControlTemplate>
                            </Setter.Value>
                        </Setter>
                    </Style>
                </Button.Style>
            </Button>
        </StackPanel>
        <Border.Triggers>
            <EventTrigger RoutedEvent="Loaded">
                <BeginStoryboard>
                    <Storyboard RepeatBehavior="Forever" AutoReverse="True">
                        <DoubleAnimation Storyboard.TargetName="SftpGlow"
                                         Storyboard.TargetProperty="Opacity"
                                         From="0.6" To="1.0"
                                         Duration="0:0:1.5"/>
                    </Storyboard>
                </BeginStoryboard>
            </EventTrigger>
        </Border.Triggers>
    </Border>
<!-- 🖥️ Run SSH Server Panel -->
<Border Background="#333"
        CornerRadius="8"
        Padding="15"
        Margin="0,15,0,20"
        BorderBrush="#dfff00"
        BorderThickness="5">
    <Border.Effect>
        <DropShadowEffect x:Name="SshGlow"
                          Color="#ffff00"
                          BlurRadius="12"
                          ShadowDepth="0"
                          Opacity="0.9"/>
    </Border.Effect>
    <StackPanel Orientation="Vertical">
        <!-- Header -->
        <TextBlock Text="🖥️ SSH Server"
                   Foreground="#dfff00"
                   FontSize="16"
                   FontWeight="Bold"
                   HorizontalAlignment="Right"
                   Margin="0,0,0,-10">
            <TextBlock.Effect>
                <DropShadowEffect Color="#ffff00"
                                  BlurRadius="12"
                                  ShadowDepth="0"
                                  Opacity="1"/>
            </TextBlock.Effect>
        </TextBlock>

        <!-- Path to sshd.exe -->
        <TextBlock Text="Path to sshd.exe:"
                   Foreground="#dfff00"
                   FontSize="11"
                   FontWeight="Bold"
                   Margin="0,0,0,-10">
            <TextBlock.Effect>
                <DropShadowEffect Color="#ffff00"
                                  BlurRadius="12"
                                  ShadowDepth="0"
                                  Opacity="1"/>
            </TextBlock.Effect>
        </TextBlock>
        <TextBox Name="SshExePath" Text="C:\Users\$env:UserName\Downloads\OpenSSH-Win64-USER-1\sshd.exe" Margin="0,10,0,10"/>

        <!-- Path to sshd_config -->
        <TextBlock Text="Path to sshd_config:"
                   Foreground="#dfff00"
                   FontSize="11"
                   FontWeight="Bold"
                   Margin="0,0,0,-10">
            <TextBlock.Effect>
                <DropShadowEffect Color="#ffff00"
                                  BlurRadius="12"
                                  ShadowDepth="0"
                                  Opacity="1"/>
            </TextBlock.Effect>
        </TextBlock>
        <TextBox Name="SshConfigPath" Text="C:\Users\$env:UserName\Downloads\OpenSSH-Win64-USER-1\sshd_config" Margin="0,10,0,10"/>
        <Button Name="RunSshButton" Content="▶ Start SSH Server" Margin="0,10,0,0">
            <Button.Style>
                <Style TargetType="Button">
                    <!-- Same inverted style as UploadButton -->
                    <Setter Property="Foreground" Value="#00008b"/>
                    <Setter Property="Background" Value="#dfff00"/>
                    <Setter Property="BorderBrush" Value="#00008b"/>
                    <Setter Property="BorderThickness" Value="2"/>
                    <Setter Property="FontSize" Value="14"/>
                    <Setter Property="FontWeight" Value="Bold"/>
                    <Setter Property="Height" Value="35"/>
                    <Setter Property="Cursor" Value="Hand"/>
                    <Setter Property="HorizontalContentAlignment" Value="Left"/>
                    <Setter Property="VerticalContentAlignment" Value="Center"/>
                    <Setter Property="Padding" Value="6,0,0,0"/>
                    <Setter Property="Template">
                        <Setter.Value>
                            <ControlTemplate TargetType="Button">
                                <Border Background="{TemplateBinding Background}"
                                        BorderBrush="{TemplateBinding BorderBrush}"
                                        BorderThickness="{TemplateBinding BorderThickness}"
                                        CornerRadius="6">
                                    <ContentPresenter HorizontalAlignment="{TemplateBinding HorizontalContentAlignment}" 
                                                    VerticalAlignment="{TemplateBinding VerticalContentAlignment}"
                                                    Margin="{TemplateBinding Padding}"/>
                                </Border>
                                <ControlTemplate.Triggers>
                                    <Trigger Property="IsMouseOver" Value="True">
                                        <Setter Property="Background" Value="#001f5c"/>
                                        <Setter Property="Foreground" Value="#dfff00"/>
                                        <Setter Property="BorderBrush" Value="#dfff00"/>
                                        <Setter Property="BorderThickness" Value="3"/>
                                    </Trigger>
                                    <Trigger Property="IsPressed" Value="True">
                                        <Setter Property="Background" Value="#001f5c"/>
                                        <Setter Property="Foreground" Value="#dfff00"/>
                                        <Setter Property="BorderBrush" Value="#dfff00"/>
                                        <Setter Property="BorderThickness" Value="4"/>
                                    </Trigger>
                                </ControlTemplate.Triggers>
                            </ControlTemplate>
                        </Setter.Value>
                    </Setter>
                </Style>
            </Button.Style>
</Button>
    </StackPanel>
    <!-- Neon glow animation -->
    <Border.Triggers>
        <EventTrigger RoutedEvent="Loaded">
            <BeginStoryboard>
                <Storyboard RepeatBehavior="Forever" AutoReverse="True">
                    <DoubleAnimation Storyboard.TargetName="SshGlow"
                                     Storyboard.TargetProperty="Opacity"
                                     From="0.6" To="1.0"
                                     Duration="0:0:1.5"/>
                </Storyboard>
            </BeginStoryboard>
        </EventTrigger>
    </Border.Triggers>
</Border>
</StackPanel>
</Window>
"@
# Read XAML
$xmlReader = New-Object System.Xml.XmlNodeReader ([xml]$xaml)
$window    = [System.Windows.Markup.XamlReader]::Load($xmlReader)
#############################################################################################################################################################################  
# ENCRYPTOR - SUPPORTS ENCRYPTION OF BOTH PASSWORD AND FILE 
#############################################################################################################################################################################
function Encrypt_String($plainText, $key, $iv) {
    $aes = [System.Security.Cryptography.Aes]::Create()
    $aes.Key = $key
    $aes.IV  = $iv
    $encryptor = $aes.CreateEncryptor()
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($plainText)
    $encrypted = $encryptor.TransformFinalBlock($bytes, 0, $bytes.Length)
    return [Convert]::ToBase64String($encrypted)
}
#############################################################################################################################################################################  
# DECRYPTOR - SUPPORTS DECRYPTION OF BOTH FILE AND PASSWORD
#############################################################################################################################################################################
function Decrypt_String($cipherText, $key, $iv) {
    $aes = [System.Security.Cryptography.Aes]::Create()
    $aes.Key = $key
    $aes.IV  = $iv
    $decryptor = $aes.CreateDecryptor()
    $cipherBytes = [Convert]::FromBase64String($cipherText)
    $decrypted = $decryptor.TransformFinalBlock($cipherBytes, 0, $cipherBytes.Length)
    return [System.Text.Encoding]::UTF8.GetString($decrypted)
}
############################################################################################################################################################################# 
# CREATE AES-256 KEY ANS SEVE IT TO SECRET STORE FOR PERSISTENCE 
#############################################################################################################################################################################
function Save-AesKeyToSecretManager {
    param(
        [string]$SecretName = "pfxKey"
    )
    # Ensure SecretManagement and SecretStore modules are available
    if (-not (Get-Module -ListAvailable -Name Microsoft.PowerShell.SecretManagement)) {
        Write-Host "Installing SecretManagement..."
        Install-Module Microsoft.PowerShell.SecretManagement -Scope CurrentUser -Force
    }
    if (-not (Get-Module -ListAvailable -Name Microsoft.PowerShell.SecretStore)) {
        Write-Host "Installing SecretStore..."
        Install-Module Microsoft.PowerShell.SecretStore -Scope CurrentUser -Force
    }
    Import-Module Microsoft.PowerShell.SecretManagement
    Import-Module Microsoft.PowerShell.SecretStore
    # Register SecretStore as default vault if none exists
    if (-not (Get-SecretVault)) {
        Register-SecretVault -Name MySecretStore -ModuleName Microsoft.PowerShell.SecretStore -DefaultVault
        Write-Host "SecretStore registered as default vault."
    }

    # Generate random 256-bit AES key (32 bytes)
    $rng = New-Object System.Security.Cryptography.RNGCryptoServiceProvider
    $key = New-Object byte[] 32
    $rng.GetBytes($key)
    # Save key as a secret
    Reset-SecretStore
    Set-SecretStoreConfiguration -Authentication Password -Interaction None
    Unlock-SecretStore
    Set-Secret -Name $SecretName -Secret $key
    Write-Host "AES key saved in SecretStore under name '$SecretName'"
}
#############################################################################################################################################################################
# SAVE - ENCRYPT PFX PASSWORD BLOB
#############################################################################################################################################################################
function Save-PfxPasswordBlob {
    param(
        [string]$SecretName = "pfxKey",
        [string]$BlobPath = "$PSScriptRoot\pfxPass"
    )

    Import-Module Microsoft.PowerShell.SecretManagement

    # Retrieve AES key from SecretStore
    $key = Get-Secret -Name $SecretName
    if (-not $key) {
        throw "Secret '$SecretName' not found. Run Save-AesKeyToSecretManager first."
    }

    # Prompt for PFX password securely
    $securePassword = Read-Host "Enter PFX password" -AsSecureString

    # Save encrypted blob to file
    $securePassword | ConvertFrom-SecureString -Key $key | Out-File $BlobPath

    Write-Host "PFX password encrypted and saved to $BlobPath"
}
############################################################################################################################################################################# 
# LOAD - DECRYPT PFX PASSWORD BLOB
#############################################################################################################################################################################
function Get-PfxPasswordForExport {
    param(
        [string]$SecretName = "pfxKey",
        [string]$BlobPath = "$PSScriptRoot\pfxPass"
    )

    Import-Module Microsoft.PowerShell.SecretManagement

    # Retrieve AES key from SecretStore
    $key = Get-Secret -Name $SecretName
    if (-not $key) {
        throw "Secret '$SecretName' not found."
    }

    # Load encrypted blob and decrypt
    $securePassword = Get-Content $BlobPath | ConvertTo-SecureString -Key $key

    return $securePassword
}
#############################################################################################################################################################################  
# CONFIGURATION JSON
#############################################################################################################################################################################
function Set-x509CertConfigJSONFile {
    # --------------------------------------------------------------------------------------------------------------------------------------------------------------
    # X.509 Certificate Settings
    # --------------------------------------------------------------------------------------------------------------------------------------------------------------
    # Set the user name, email address, DNS names - optional - may be @(""), and other attributes as needed.
    $type                = "Custom"
    $userName            = "X Y ♕Limited♕ [＠ROOT CERTIFICATE AUTHORITY]"
    $userEmail           = "X.Y@users.noreply.github.com"
    $dnsNames            = @("github.com")
    $dnsName             = ($dnsNames -join ", ")
    $certStoreLocation   = "Cert:\CurrentUser\My"
    $localTrustedRootCA  = "Cert:\CurrentUser\Root"
    $keyAlgorithm        = "RSA"
    $keyLength           = 4096
    $hashAlgorithm       = "SHA256"
    $keyExportPolicy     = "Exportable"
    $keyUsage            = @("DigitalSignature", "KeyEncipherment")
    $textExtension       = @("2.5.29.37={text}1.3.6.1.5.5.7.3.2,1.3.6.1.5.5.7.3.3,1.3.6.1.5.5.7.3.4,1.3.6.1.5.5.7.3.8,1.3.6.1.4.1.311.10.3.12")
    <# 
    2.5.29.37 : OID for Extended Key Usage (EKU)
    EKU Purpose	                OID	Description             Description
    Server Authentication	    1.3.6.1.5.5.7.3.1	        Allows certificate to authenticate a server (e.g., HTTPS/TLS)
    Client Authentication	    1.3.6.1.5.5.7.3.2	        Allows certificate to authenticate a client (e.g., mutual TLS)
    Code Signing	            1.3.6.1.5.5.7.3.3	        Allows signing of executables and scripts
    Secure Email	            1.3.6.1.5.5.7.3.4	        Enables S/MIME email signing and encryption
    IP Security End System	    1.3.6.1.5.5.7.3.5	        Used for IPsec end systems (hosts)
    IP Security Tunnel Endpoint	1.3.6.1.5.5.7.3.6	        Used for IPsec VPN tunnel endpoints
    IP Security User	        1.3.6.1.5.5.7.3.7	        Used for IPsec user authentication
    Time Stamping	            1.3.6.1.5.5.7.3.8	        Allows signing of timestamps
    OCSP Signing	            1.3.6.1.5.5.7.3.9	        Allows signing of OCSP responses
    DVCS Signing	            1.3.6.1.5.5.7.3.10	        Data validation and certification service signing
    Document Signing	        1.3.6.1.4.1.311.10.3.12	    Microsoft-specific EKU for document signing
    Smart Card Logon	        1.3.6.1.4.1.311.20.2.2	    Microsoft-specific EKU for smart card authentication
    Enrollment Agent	        1.3.6.1.4.1.311.20.2.1	    Allows certificate enrollment on behalf of other users
    Any Extended Key Usage	    2.5.29.37.0	                Wildcard EKU - allows all usages (not recommended for strict environments)
    #>
    # --------------------------------------------------------------------------------------------------------------------------------------------------------------
    # Paths def.
    # --------------------------------------------------------------------------------------------------------------------------------------------------------------

    $certFolder = "$PSScriptRoot\.cert"
    $pfxPath    = "$certFolder\Personal_Information_Exchange-$userName.pfx"
    $cerPath    = "$certFolder\X.509_Certificate-$userName.cer"
    $configPath = "$PSScriptRoot\x509-cert-config.json"

    ################################################################################################################################################################
    # CREATE JSON FILE
    ################################################################################################################################################################
    # Ensure .cert folder exists
    if (-not (Test-Path $certFolder)) {
        New-Item -Path $certFolder -ItemType Directory | Out-Null
    }
    # Create config object
    $config = [ordered]@{
    type               = $type
    userName           = $userName
    userEmail          = $userEmail
    dnsName            = $dnsName
    certStoreLocation  = $certStoreLocation
    localTrustedRootCA = $localTrustedRootCA
    keyAlgorithm       = $keyAlgorithm
    keyLength          = $keyLength
    hashAlgorithm      = $hashAlgorithm 
    keyExportPolicy    = $keyExportPolicy
    keyUsage           = $keyUsage
    textExtension      = $textExtension
    pfxPassword        = $pfxPassword
    pfxPath            = $pfxPath
    cerPath            = $cerPath
    infPath            = $infPath
    }
    # Convert to JSON and save
    $json = $config | ConvertTo-Json 
    Set-Content -Path $configPath -Value $json -Encoding UTF8
    Write-Host "File x509-cert-config.json has been created at $configPath" -ForegroundColor Cyan
}
#############################################################################################################################################################################  
# CREATE x509 CERTIFICATE
#############################################################################################################################################################################
function Set-PFX_Personal_Information_Exchange_Crypto_Container {
    param (
        [Parameter(Mandatory=$true)]
        [pscustomobject]$configJSON
    )
    $PFX_Crypto_Data_Container = New-SelfSignedCertificate `
        -Type $configJSON.type `
        -Subject "CN=$($configJSON.userName), E=$($configJSON.userEmail)" `
        -DnsName $configJSON.dnsName `
        -CertStoreLocation $configJSON.certStoreLocation `
        -KeyAlgorithm $configJSON.keyAlgorithm `
        -KeyLength $configJSON.keyLength `
        -HashAlgorithm $configJSON.hashAlgorithm `
        -KeyExportPolicy $configJSON.keyExportPolicy `
        -KeyUsage $configJSON.keyUsage `
        -TextExtension $configJSON.textExtension

    return $PFX_Crypto_Data_Container
}
#############################################################################################################################################################################
# 2. EXPORT CERTIFICATE 
#############################################################################################################################################################################
# ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Once the certificate is created, you export it to .pfx  (private + public key) and .cer (public key only) files.
# ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# This export is from Personal Store to Local File System (.cert directory)   
# ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function Export-CertificateBundle {
    param (
        [Parameter(Mandatory=$true)]
        [string]$pfxPath,

        [Parameter(Mandatory=$true)]
        [string]$cerPath,

        [Parameter(Mandatory=$true)]
        [System.Security.Cryptography.X509Certificates.X509Certificate2]$cert,

        [Parameter(Mandatory=$true)]
        [securestring]$pfxPassword
    )
    try {
        # EXPORT FROM STORE TO LOCAL FILE SYSTEM TO GET .PFX (PKCS#12) 
        # Purpose: Export private key and certificate
        Export-PfxCertificate -Cert $cert -FilePath $pfxPath -Password $pfxPassword
        
        # EXPORT FROM STORE TO LOCAL FILE SYSTEM TO GET .CER (X.509) 
        # Purpose: Export public key only
        Export-Certificate -Cert $cert -FilePath $cerPath

        # Confirmation
        Write-Host "Certificate exported successfully:" -ForegroundColor Cyan
        Write-Host "→ Subject:       $($cert.Subject)" 
        Write-Host "→ FriendlyName:  $($cert.FriendlyName)"
        Write-Host "→ PFX Path:      $pfxPath"
        Write-Host "→ CER Path:      $cerPath"
    }
    catch {
        Write-Host "Error during export: $($_.Exception.Message)" -ForegroundColor DarkRed
    }
}
#############################################################################################################################################################################
# 3. IMPORT CERTIFICATE
#############################################################################################################################################################################
# ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Import cer. from Local File System to Local Store
# ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

<#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Store Name             |           Display Name
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
My	                   |           Personal
Root	               |           Trusted Root Certification Authorities
CA	                   |           Intermediate Certification Authorities
TrustedPeople	       |           Trusted People
TrustedPublisher       |           Trusted Publishers
AddressBook	           |           Other People
AuthRoot	           |           Third-Party Root Certification Authorities
Disallowed	           |           Untrusted Certificates
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------#>
function Import-Certificate_To_Stores {    
    $stores    = @("My", "Root",  "CA", "TrustedPeople", "TrustedPublisher", "AddressBook")
    $locations = @("CurrentUser")  #$locations = @("CurrentUser", "LocalMachine")
    foreach ($location in $locations) {
        foreach ($store in $stores) {
            $certLocalStorePath = "Cert:\$location\$store"
            if (Test-Path $certLocalStorePath) {
                $certLocalFileSystemPath = $configJSON.cerPath
                if (Test-Path -LiteralPath $certLocalFileSystemPath) {
                    Write-Host "Importing certificate   |   $certLocalFileSystemPath   |   $certLocalStorePath" -ForegroundColor Cyan
                    try {
                        $cert = Import-Certificate -FilePath $certLocalFileSystemPath -CertStoreLocation $certLocalStorePath
                        if ($cert) {
                            Write-Host "Certificate imported successfully:" -ForegroundColor Cyan
                        } else {
                            Write-Host "Certificate import failed" -ForegroundColor DarkRed
                        }
                    }
                    catch {
                        Write-Host "Error during import: $($_.Exception.Message)" -ForegroundColor DarkRed
                    }            
                } 
            }
        }
    }
}
# Import-Certificate_To_Stores

#############################################################################################################################################################################
# Get-ChrootDirPath
#############################################################################################################################################################################
function Set-ChrootLabel { 
    param ( 
        [System.Windows.Controls.TextBlock]$chrootLabel, 
        [Boolean]$isSSHDrunning, 
        [string]$chrootDirLine ) 
        $inputHost = $hostInput.Text 
        $resolvedHost = Resolve_SFTPHost -InputHost $inputHost 
        $port = $portInput.Text 
        $user = $userInput.Text 
        $key = $keyInput.Text 
        if (-not ($resolvedHost -and $port -and $user)) { 
            [System.Windows.MessageBox]::Show("Please fill in host, port and username.","Missing SFTP Info") 
            return 
        } 
        $chrootDirLine = & ssh.exe -i "$key" -p $port "$user@$resolvedHost" "echo %cd%" 2>&1 
        if ($isSSHDrunning) {
            if ($LASTEXITCODE -eq 0 -and $chrootDirLine) { 
                $tokens = $chrootDirLine -split '\s+' 
                $path = $tokens[-1] 
                $warning = ($tokens[0..($tokens.Length-2)] -join ' ') 
                if ($warning.StartsWith("c:", [System.StringComparison]::OrdinalIgnoreCase)) {
                    $warning=""
                }
                $formatted = "$path`n$warning" 
                $chrootLabel.TextWrapping = "Wrap" 
                $chrootLabel.Text = "📂 SFTP Session Root Directory: $formatted" 
            } 
        }else { 
            $chrootLabel.Text = "📂 SFTP Session Root Directory: (Could not detect <=> SSHD Server is not running)" 
        } 
    }
#############################################################################################################################################################################
# Get-WhoAmI
#############################################################################################################################################################################
function Get-WhoAmI {
    # Run the whoami command and return its output
    $result = whoami
    return $result
}
#############################################################################################################################################################################
# MAIN FUNCTION
#############################################################################################################################################################################
function Show_Window {
    $reader = [System.Xml.XmlReader]::Create([System.IO.StringReader]$xaml)
    $window = [Windows.Markup.XamlReader]::Load($reader)

    $passwordBox     = $window.FindName("PasswordInput")
    $encryptButton   = $window.FindName("EncryptButton")
    $decryptButton   = $window.FindName("DecryptButton")
    $createPfxButton = $Window.FindName("CreatePfxButton")
    $signButton      = $window.FindName("SignButton")
    $verifyButton    = $window.FindName("VerifyButton")
    $uploadButton    = $window.FindName("UploadButton")
    $hostInput       = $window.FindName("HostInput")
    $portInput       = $window.FindName("PortInput")
    $userInput       = $window.FindName("UserInput")
    $userInput.Text  = Get-WhoAmI
    $keyInput        = $window.FindName("KeyInput")
    $ChrootLabel     = $window.FindName("chrootLabel")
    Set-ChrootLabel -chrootLabel $ChrootLabel -isSSHDrunning $False -chrootDirLine=""
    $keyInput.Add_TextChanged({
    $isSSHDrunning = $null -ne (Get-Process -Name "sshd" -ErrorAction SilentlyContinue)
    Set-ChrootLabel -chrootLabel $ChrootLabel -isSSHDrunning $isSSHDrunning -chrootDirLine ""
    })
    $SshExePath      = $window.FindName("SshExePath")
    $SshConfigPath   = $window.FindName("SshConfigPath")
    $RunSshButton    = $window.FindName("RunSshButton")
    ########################################################################################################################################################################
    # ENCRYPT PASSWORD
    # ENCRYPT CONFIG FILE
    ########################################################################################################################################################################
    $encryptButton.Add_Click({
        # ENCRYPT PASSWORD
        $plainPassword = $passwordBox.Password
        if (![string]::IsNullOrEmpty($plainPassword)) {
            $aes_256_for_password = [System.Security.Cryptography.Aes]::Create()
            $aes_256_for_password.KeySize = 256
            $aes_256_for_password.GenerateKey()
            $aes_256_for_password.GenerateIV()
            $encryptedPassword = Encrypt_String $plainPassword $aes_256_for_password.Key $aes_256_for_password.IV
            $config = @{
                pfxPassword = $encryptedPassword
                Key         = [Convert]::ToBase64String($aes_256_for_password.Key)
                IV          = [Convert]::ToBase64String($aes_256_for_password.IV)
            }
            $config | ConvertTo-Json | Set-Content ".\config.json"
            [System.Windows.MessageBox]::Show("Password encrypted and saved to config.json.","Success")
            # ENCRYPT CONFIG.JSON FILE
            $configJSONFileContent = Get-Content ".\config.json" -Raw
            # Generate AES key and IV TO ENCRYPT CONFIG FILE
            $aes_256_for_file = [System.Security.Cryptography.Aes]::Create()
            $aes_256_for_file.KeySize = 256
            $aes_256_for_file.GenerateKey()
            $aes_256_for_file.GenerateIV()
        
            # Save raw key and IV as binary files
            [System.IO.File]::WriteAllBytes("$PSScriptRoot\aes_256_for_file.key", $aes_256_for_file.Key)
            [System.IO.File]::WriteAllBytes("$PSScriptRoot\aes_256_for_file.iv",  $aes_256_for_file.IV)
            # Save raw key and IV as Base64 String
            # [System.IO.File]::WriteAllText("$PSScriptRoot\aes_256_for_file.key", [Convert]::ToBase64String($aes_256_for_file.Key))
            # [System.IO.File]::WriteAllText("$PSScriptRoot\aes_256_for_file.iv",  [Convert]::ToBase64String($aes_256_for_file.IV))
        
            Write-Host "AES-256 key saved to aes_256_for_file.key" -ForegroundColor Cyan
            Write-Host "AES IV saved to aes_256_for_file.iv" -ForegroundColor Cyan
            
            # Encrypt the JSON string
            $encrypted = Encrypt_String $configJSONFileContent $aes_256_for_file.Key $aes_256_for_file.IV
            # Save encrypted content to file
            Set-Content ".\config.json" $encrypted
            Rename-Item ".\config.json" "config.enc" 
            
            [System.Windows.MessageBox]::Show("File config.json is encrypted and renamed to config.enc.","Success")
        } else {
            [System.Windows.MessageBox]::Show("Please enter a password.","Missing Input")
        }
    })
    ########################################################################################################################################################################
    # DECRYPT CONFIG FILE
    # DECRYPT PASSWORD
    ########################################################################################################################################################################
    $decryptButton.Add_Click({
        # Load AES key
        $keyPath = "$PSScriptRoot\aes_256_for_file.key"
        if (-not (Test-Path $keyPath)) {
            Write-Error "Encryption key not found at $keyPath"
            return
        }
        $key = [System.IO.File]::ReadAllBytes($keyPath)
        # If key was saved as Base64 instead of raw bytes:
        # $key = [Convert]::FromBase64String((Get-Content $keyPath -Raw))

        # Load AES IV
        $ivPath = "$PSScriptRoot\aes_256_for_file.iv"
        if (-not (Test-Path $ivPath)) {
            Write-Error "IV file not found at $ivPath"
            return
        }
        $iv = [System.IO.File]::ReadAllBytes($ivPath)
        # If iv was saved as Base64 instead of raw bytes:
        # $iv = [Convert]::FromBase64String((Get-Content $ivPath -Raw))
       
        # Validate path to config file
        if (-not (Test-Path ".\config.enc")) {
            [System.Windows.MessageBox]::Show("Config file not found.","Missing File")
            return
        }

        try {
            ####################################################################################################################################
            #DECRYPT CONFIG FILE
            ####################################################################################################################################
            $encrypted = Get-Content ".\config.enc" -Raw
            $decrypted = Decrypt_String $encrypted $key $iv
            ####################################################################################################################################
            $config = $decrypted | ConvertFrom-Json
            ####################################################################################################################################
            # DECRYPT PASSWORD
            ####################################################################################################################################
            $key = [Convert]::FromBase64String($config.key)
            $iv  = [Convert]::FromBase64String($config.iv)
            $cipher = $config.pfxPassword

            $plain = Decrypt_String $cipher $key $iv
            [System.Windows.MessageBox]::Show("Decrypted password:`n$plain","Decryption Successful")
        } catch {
            [System.Windows.MessageBox]::Show("Decryption failed: $_","Error")
        }
    })
    ########################################################################################################################################################################
    # Create PFX Certificate
    ########################################################################################################################################################################
    $createPfxButton.Add_Click({
        try {
            Set-x509CertConfigJSONFile
            # SETUP
            # 1. Load config.json file for creating cert. via PowerShell PKI API 
            $configJSON = Get-Content -Path "$PSScriptRoot\x509-cert-config.json" -Raw | ConvertFrom-Json
            # 2. Save AES key to SecretStore (only once)
            Save-AesKeyToSecretManager -SecretName "pfxKey"
            # 3. Save encrypted PFX password blob
            Save-PfxPasswordBlob -SecretName "pfxKey" -BlobPath "$PSScriptRoot\pfxPass"
            ################################################################################################################################################################
            # CREATE CERTIFICATE                                                                                       
            ################################################################################################################################################################
            # This step generates the certificate and private key using New-SelfSignedCertificate function from PKI PowerShell mod. or a certificate request via certreq.exe
            # --------------------------------------------------------------------------------------------------------------------------------------------------------------
            # Create Personal Information Exchange (.pfx) container with crypto data in data structure: private key, certificate .cer (.X509), password, and certs chain (CA)
            # --------------------------------------------------------------------------------------------------------------------------------------------------------------
            # File .pfx (Windows) is technically equivalent to PKCS#12 or .p12 (Unix/macOS) - they represent the same format and structure, differing only by file extension
            # --------------------------------------------------------------------------------------------------------------------------------------------------------------
            # Return: Function generates .pfx file, and saves it in User Local Personal Certificates Storage Location.
            # --------------------------------------------------------------------------------------------------------------------------------------------------------------            
            $PFX_Crypto_Data_Container = Set-PFX_Personal_Information_Exchange_Crypto_Container -configJSON $configJSON
            $PFX_Crypto_Data_Container | Format-List Subject, Issuer, FriendlyName, Thumbprint           
            # Load PFX password blob and use in export
            $securePassword = Get-PfxPasswordForExport -SecretName "pfxKey" -BlobPath "$PSScriptRoot\pfxPass"
            Export-CertificateBundle -pfxPath $configJSON.pfxPath -cerPath $configJSON.cerPath -cert $PFX_Crypto_Data_Container -pfxPassword $securePassword            
            [System.Windows.MessageBox]::Show("PFX certificate created at $($configJSON.cerPath)","Success")
        }
        catch {
            [System.Windows.MessageBox]::Show("Error creating PFX: $_","Error")
        }
    })
    #########################################################################################################################################################################
    # FILE (file.sig) SIGNATURE (via .pfx file - private key) 
    #########################################################################################################################################################################
    Add-Type -AssemblyName PresentationFramework
    $signButton.Add_Click({
        # Select file
        $fileDialog = New-Object Microsoft.Win32.OpenFileDialog
        $fileDialog.Filter = "All files (*.*)|*.*"
        if (-not $fileDialog.ShowDialog()) { return }
        $filePath = $fileDialog.FileName
        # Select PFX
        $pfxDialog = New-Object Microsoft.Win32.OpenFileDialog
        $pfxDialog.Filter = "PFX files (*.pfx)|*.pfx"
        if (-not $pfxDialog.ShowDialog()) { return }
        $pfxPath = $pfxDialog.FileName
        # Load file bytes
        $fileBytes = [System.IO.File]::ReadAllBytes($filePath)
        # Compute SHA256 hash
        $hasher = [System.Security.Cryptography.SHA256]::Create()
        $hash   = $hasher.ComputeHash([byte[]]$fileBytes)
        # Get PFX password
        $pfxPassword = Read-Host -Prompt "Enter PFX password:" -AsSecureString
        try {
            $cert = [System.Security.Cryptography.X509Certificates.X509Certificate2]::new(
                $pfxPath,
                $pfxPassword,
                [System.Security.Cryptography.X509Certificates.X509KeyStorageFlags]::Exportable
            )
            $rsa = [System.Security.Cryptography.X509Certificates.RSACertificateExtensions]::GetRSAPrivateKey($cert)
            if (-not $rsa) { Write-Error "RSA private key could not be retrieved."; return }

            $signedHash = $rsa.SignHash(
                $hash,
                [System.Security.Cryptography.HashAlgorithmName]::SHA256,
                [System.Security.Cryptography.RSASignaturePadding]::Pkcs1
            )
            $sigPath = "$filePath.sig"
            [System.IO.File]::WriteAllBytes($sigPath, $signedHash)
            Write-Host "Signature saved to: $sigPath"
        }
        catch {
            Write-Error "Sign file with PFX failed: $_"
        }
    })
    #########################################################################################################################################################################
    # FILE (file.sig) SIGNATURE (via .pfx file - private key) VERIFiER (via .cer file - public key)
    #########################################################################################################################################################################
    Add-Type -AssemblyName PresentationFramework
    $verifyButton.Add_Click({
        # Select file
        $fileDialog = New-Object Microsoft.Win32.OpenFileDialog
        $fileDialog.Filter = "All files (*.*)|*.*"
        if (-not $fileDialog.ShowDialog()) { return }
        $filePath = $fileDialog.FileName
        # Select signature
        $sigDialog = New-Object Microsoft.Win32.OpenFileDialog
        $sigDialog.Filter = "Signature files (*.sig)|*.sig"
        if (-not $sigDialog.ShowDialog()) { return }
        $sigPath = $sigDialog.FileName
        # Select certificate
        $cerDialog = New-Object Microsoft.Win32.OpenFileDialog
        $cerDialog.Filter = "Certificate files (*.cer)|*.cer"
        if (-not $cerDialog.ShowDialog()) { return }
        $cerPath = $cerDialog.FileName
        # Load certificate
        $cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2 $cerPath
        $rsa  = [System.Security.Cryptography.X509Certificates.RSACertificateExtensions]::GetRSAPublicKey($cert)
        # Load file and signature
        $bytes     = [System.IO.File]::ReadAllBytes($filePath)
        $signature = [System.IO.File]::ReadAllBytes($sigPath)
        # Compute SHA256 hash
        $hasher = [System.Security.Cryptography.SHA256]::Create()
        $hash   = $hasher.ComputeHash([byte[]]$bytes)
        # Verify signature
        $valid = $rsa.VerifyHash(
            $hash,
            $signature,
            [System.Security.Cryptography.HashAlgorithmName]::SHA256,
            [System.Security.Cryptography.RSASignaturePadding]::Pkcs1
        )

        if ($valid) {
            [System.Windows.MessageBox]::Show("Signature is valid.","Verified")
        } else {
            [System.Windows.MessageBox]::Show("Signature is NOT valid.","Verification Failed")
        }
    })
    #########################################################################################################################################################################
    # SEND UPLOADED FILE VIA SFTP TO SSH SERVER
    #########################################################################################################################################################################
    $uploadButton.Add_Click({
    $inputHost    = $hostInput.Text
    $resolvedHost = Resolve_SFTPHost -InputHost $inputHost
    $port         = $portInput.Text
    $user         = $userInput.Text
    $key          = $keyInput.Text
    if (-not ($resolvedHost -and $port -and $user)) {
        [System.Windows.MessageBox]::Show("Please fill in host, port and username.","Missing SFTP Info")
        return
    }
    # File selection dialog
    Add-Type -AssemblyName System.Windows.Forms
    $fileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $fileDialog.Title = "Select file to upload"
    $fileDialog.Filter = "All files (*.*)|*.*"
    if ($fileDialog.ShowDialog() -ne "OK") { return }
    $filePath = $fileDialog.FileName
    $fileName = [System.IO.Path]::GetFileName($filePath)
    # Normalize local path to forward slashes
    $filePath = $filePath -replace '\\','/'
    # Strip domain if present
    #$userNameOnly = $user -replace '.*\\', ''
    # Remote path: use current SFTP directory (chroot jail root)
    $remotePath = "./$fileName"
    # Create temporary batch file for SFTP commands
    $sftpBatch = [System.IO.Path]::GetTempFileName()
    Set-Content -Path $sftpBatch -Value "put `"$filePath`" `"$remotePath`""
    # Upload file
    $output = & sftp.exe -b "$sftpBatch" -i "$key" -P $port "$user@$resolvedHost" 2>&1
    if ($LASTEXITCODE -eq 0) {
        [System.Windows.MessageBox]::Show("File uploaded via SFTP.","Upload Complete")
    } else {
        [System.Windows.MessageBox]::Show("Upload failed:`n$output","Error")
    }
    Remove-Item $sftpBatch -ErrorAction SilentlyContinue
    })
    #########################################################################################################################################################################
    # RUN SSH SERVER
    #########################################################################################################################################################################
    $p = $null
    $RunSshButton.Add_Click({
        $exePath    = $SshExePath.Text
        $configPath = $SshConfigPath.Text
        $logFile    = Join-Path $env:USERPROFILE 'sshd_run.log'
        if (-not (Test-Path $exePath)) {
            [System.Windows.MessageBox]::Show("sshd.exe not found at $exePath","Error")
            return
        }
        if (-not (Test-Path $configPath)) {
            [System.Windows.MessageBox]::Show("sshd_config not found at $configPath","Error")
            return
        }
        $arguments = "-f `"$configPath`""
        $p = Start-Process -FilePath $exePath `
                        -ArgumentList $arguments `
                        -WindowStyle Hidden `
                        -RedirectStandardOutput "$logFile.out" `
                        -RedirectStandardError  "$logFile.err" `
                        -PassThru

        if ($p) {
            Set-ChrootLabel -chrootLabel $ChrootLabel -isSSHDrunning $true -chrootDirLine=""
            $p.EnableRaisingEvents = $true
            Register-ObjectEvent -InputObject $p -EventName Exited -Action {
                [System.Windows.MessageBox]::Show(
                    "SSH Server stopped unexpectedly. See logs:`n$logFile.out`n$logFile.err",
                    "Error"
                )
            }
            [System.Windows.MessageBox]::Show("SSH Server started. Logs:`n$logFile.out`n$logFile.err","Success")
        }
        else {
            [System.Windows.MessageBox]::Show("Failed to start SSH Server.","Error")
        }
    })
$window.ShowDialog() | Out-Null
}
#############################################################################################################################################################################
# PARSER FOR INPUT HOST VALUE (It supports both formats e.g. FQDN and IP e.g. $hostInput = "sftp.host.com" or $hostInput = "192.168.1.10") accepted
############################################################################################################################################################################# 
function Resolve_SFTPHost {
    param (
        [string]$InputHost
    )
    try {
        $resolved = [System.Net.Dns]::GetHostAddresses($InputHost) | Where-Object { $_.AddressFamily -eq 'InterNetwork' }
        if ($resolved.Count -gt 0) {
            return $resolved[0].IPAddressToString
        } else {
            return $null
        }
    } catch {
        Write-Host "Error resolving hostname: $_"
        return $null
    }
}
function Stop-Sshd {
    param(
        [int]$ProcessID,
        [switch]$Force
    )
    if ($ProcessID) {
        try {
            & taskkill /T /PID $ProcessID /F | Out-Null
            return
        } catch { }
    }
    if ($ProcessID) {
        try {
            $children = Get-CimInstance Win32_Process -Filter "ParentProcessId=$ProcessID"
            foreach ($c in $children) {
                try { Stop-Process -Id $c.ProcessId -Force:$Force } catch { }
            }
        } catch { }
    }
    try {
        Get-Process -Name 'sshd' -ErrorAction SilentlyContinue | ForEach-Object {
            try { Stop-Process -Id $_.Id -Force:$Force } catch { }
        }
    } catch { }
}
############################################################################################################################################################################# 
# ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# CALL MAIN FUNCTION WIN FORM APP
# ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
############################################################################################################################################################################# 
# CLIENT-SERVER WIN APP FOR A SECURE FILES TRANSFER
############################################################################################################################################################################# 
Show_Window