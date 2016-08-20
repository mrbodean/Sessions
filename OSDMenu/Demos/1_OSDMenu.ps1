param
(
	[string]$Domain
)


[void][System.Reflection.Assembly]::LoadWithPartialName('presentationframework')
[xml]$XAML = @'
<Window
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
    Title="IT Pro Camp OS Deployment" Height="350" Width="525" Name="PxOSDMenu" Topmost="True" WindowStartupLocation="CenterScreen" WindowStyle="SingleBorderWindow">
    <Grid>
        <TextBox Height="26" HorizontalAlignment="Left" Margin="246,29,0,0" Name="compname_txt" VerticalAlignment="Top" Width="247" />
        <Label Content="Computername:" Height="28" HorizontalAlignment="Left" Margin="18,28,0,0" Name="Compname_Label" VerticalAlignment="Top" Width="211" />
        <ComboBox Height="27" HorizontalAlignment="Left" Margin="246,69,0,0" Name="PxLifecycle_box" VerticalAlignment="Top" Width="245">
            <ComboBoxItem Content="Production" IsSelected="True" />
            <ComboBoxItem Content="Staging" />
            <ComboBoxItem Content="Test" />
            <ComboBoxItem Content="Development" />
        </ComboBox>
        <Label Content="Select Lifecycle" Height="28" HorizontalAlignment="Left" Margin="18,69,0,0" Name="PxLifecycle_Label" VerticalAlignment="Top" Width="211" />
        <Rectangle Height="28" HorizontalAlignment="Left" Margin="246,114,0,0" Name="Timezone_group" Stroke="Black" VerticalAlignment="Top" Width="245" StrokeThickness="0" />
        <RadioButton Content="Eastern" Height="16" HorizontalAlignment="Left" Margin="270,119,0,0" Name="EasternTz_Button" VerticalAlignment="Top" IsChecked="True" GroupName="Tz" />
        <RadioButton Content="Central" Height="16" HorizontalAlignment="Left" IsChecked="False" Margin="349,119,0,0" Name="CenteralTz_Button" VerticalAlignment="Top" GroupName="Tz" />
        <Label Content="Select Timezone" Height="28" HorizontalAlignment="Left" Margin="18,114,0,0" Name="Tz_Label" VerticalAlignment="Top" Width="211" />
        <Button Content="Continue" Height="23" HorizontalAlignment="Left" Margin="207,196,0,0" Name="Continue_Button" VerticalAlignment="Top" Width="75" />
    </Grid>
</Window>
'@
#Read XAML
$reader=(New-Object System.Xml.XmlNodeReader $xaml) 
$Form=[Windows.Markup.XamlReader]::Load( $reader )
#Add Form objects as variables
$xaml.SelectNodes("//*[@Name]") | %{Set-Variable -Name ($_.Name) -Value $Form.FindName($_.Name)}
if($Domain.ToUpper() -eq "LAB"){
    $Continue_Button.IsEnabled = $false #Disable the continue button until some validation is done 
    $compname_txt.add_LostFocus({
        Switch -regex ($($compname_txt.Text.ToString()))
        {
            "\d{8}\z"{$Continue_Button.IsEnabled = $true}
            default{
                $compname_txt.Text = "Invalid Computer name!"
                $Continue_Button.IsEnabled = $false
            }
        }
    })
}
$EasternTz_Button.add_Loaded({$Script:Tz_selection = "Eastern"})
$EasternTz_Button.add_Checked({$Script:Tz_selection = "Eastern"})
$CenteralTz_Button.add_Checked({$Script:Tz_selection = "Central"})
$PxLifecycle_box.add_Loaded({$script:PxLifecycle = $PxLifecycle_box.SelectedItem.Content.ToString()})
$PxLifecycle_box.add_SelectionChanged({$script:PxLifecycle = $PxLifecycle_box.SelectedItem.Content.ToString()})
$Continue_Button.add_Click({
    $script:computername = $compname_txt.Text.ToString()
    $Form.close()
})



$Form.ShowDialog() | out-null
Write-output "Computer Name: $computername"
Write-output "Timezone: $Tz_selection"
Write-output "Lifecycle: $PxLifecycle"