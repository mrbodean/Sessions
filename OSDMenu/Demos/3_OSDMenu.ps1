param
(
	[string]$Domain,
    [switch]$testing
)

If($testing -eq $false){
    $tsenv = New-Object -COMObject Microsoft.SMS.TSEnvironment
    $tsui = New-Object -COMObject Microsoft.SMS.TSProgressUI
    $OSDComputername = $tsenv.value("OSDComputername")
    $tsui.closeprogressdialog()
}


[void][System.Reflection.Assembly]::LoadWithPartialName('presentationframework')
[xml]$XAML = @'
<Window
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
    Title="IT Pro Camp OS Deployment" Height="350" Width="525" Name="PxOSDMenu" Topmost="True" WindowStartupLocation="CenterScreen" WindowStyle="SingleBorderWindow">
    <Grid>
        <TextBlock Height="96" HorizontalAlignment="Left" Margin="18,135,0,0" Name="Status_txt" Text="" VerticalAlignment="Top" Width="463" TextWrapping="Wrap" Background="White"></TextBlock>
        <TextBox Height="26" HorizontalAlignment="Left" Margin="246,13,0,0" Name="compname_txt" VerticalAlignment="Top" Width="247" />
        <Label Content="Computername:" Height="28" HorizontalAlignment="Left" Margin="18,11,0,0" Name="Compname_Label" VerticalAlignment="Top" Width="211" />
        <ComboBox Height="27" HorizontalAlignment="Left" Margin="246,44,0,0" Name="PxLifecycle_box" VerticalAlignment="Top" Width="245">
            <ComboBoxItem Content="Production" IsSelected="True" Name="Prod_Security" />
            <ComboBoxItem Content="Staging" Name="Staging_Security" />
            <ComboBoxItem Content="Test" Name="Test_Security" />
            <ComboBoxItem Content="Development" Name="Dev_Security" />
        </ComboBox>
        <Label Content="Select Lifecycle" Height="28" HorizontalAlignment="Left" Margin="18,45,0,0" Name="PxLifecycle_Label" VerticalAlignment="Top" Width="211" />
        <Rectangle Height="28" HorizontalAlignment="Left" Margin="246,79,0,0" Name="Timezone_group" Stroke="Black" VerticalAlignment="Top" Width="245" StrokeThickness="0" />
        <RadioButton Content="Eastern" Height="16" HorizontalAlignment="Left" Margin="246,84,0,0" Name="EasternTz_Button" VerticalAlignment="Top" IsChecked="True" GroupName="Tz" />
        <RadioButton Content="Central" Height="16" HorizontalAlignment="Left" IsChecked="False" Margin="345,84,0,0" Name="CenteralTz_Button" VerticalAlignment="Top" GroupName="Tz" />
        <Label Content="Select Timezone" Height="28" HorizontalAlignment="Left" Margin="18,79,0,0" Name="Tz_Label" VerticalAlignment="Top" Width="211" />
        <Button Content="Continue" Height="23" HorizontalAlignment="Left" Margin="345,265,0,0" Name="Continue_Button" VerticalAlignment="Top" Width="146" />
        <Rectangle Height="130" HorizontalAlignment="Right" Margin="0,113,10,0" Name="RBM_box" Stroke="Black" VerticalAlignment="Top" Width="481" IsEnabled="False" Visibility="Hidden" />
        <RadioButton Content="Production" Height="16" HorizontalAlignment="Left" Margin="246,0,0,116" Name="Prod_button" VerticalAlignment="Bottom" IsChecked="True" GroupName="RBM" IsEnabled="False" Visibility="Hidden" />
        <RadioButton Content="Staging" Height="16" HorizontalAlignment="Right" Margin="0,179,114,0" Name="Stag_button" VerticalAlignment="Top" GroupName="RBM" IsEnabled="False" Visibility="Hidden"/>
        <RadioButton Content="Test" Height="16" HorizontalAlignment="Left" Margin="403,181,0,0" Name="Test_button" VerticalAlignment="Top" GroupName="RBM" IsEnabled="False" Visibility="Hidden" />
        <RadioButton Content="Dev" Height="16" HorizontalAlignment="Right" Margin="0,180,22,0" Name="Dev_Button" VerticalAlignment="Top" GroupName="RBM" IsEnabled="False" Visibility="Hidden" />
        <Label Content="Select Build Environment" Height="28" HorizontalAlignment="Left" Margin="18,0,0,109" Name="RBM_Label" VerticalAlignment="Bottom" Width="211" IsEnabled="False" Visibility="Hidden" />
        <Label Content="Select Build Server" Height="28" HorizontalAlignment="Left" Margin="18,203,0,0" Name="RBM_SRV_Label" VerticalAlignment="Top" Width="211" IsEnabled="False" Visibility="Hidden" />
        <ComboBox Height="27" HorizontalAlignment="Left" Margin="246,204,0,0" Name="RBMSRV_combo" VerticalAlignment="Top" Width="235" IsEnabled="False" Visibility="Hidden" >
            <ComboBoxItem Content="Server1" IsSelected="True" Name="DataCenter" />
            <ComboBoxItem Content="Server2" Name="StagingCenter" />
            <ComboBoxItem Content="Server3" Name="DTO" />
        </ComboBox>
        <Label Content="Select Build Location" Height="28" HorizontalAlignment="Left" Margin="18,148,0,0" Name="RBMLocation_Label" VerticalAlignment="Top" Width="211" IsEnabled="False" Visibility="Hidden" />
        <RadioButton Content="Store" GroupName="RBM_location" Height="16" HorizontalAlignment="Left" IsChecked="True" Margin="246,153,0,0" Name="Store_Button" VerticalAlignment="Top" IsEnabled="False" Visibility="Hidden" />
        <RadioButton Content="Build Center" GroupName="RBM_location" Height="16" HorizontalAlignment="Left" IsChecked="False" Margin="295,153,0,0" Name="ISTSStaging_Button" VerticalAlignment="Top" IsEnabled="False" Visibility="Hidden" />
        <RadioButton Content="Lab" GroupName="RBM_location" Height="16" HorizontalAlignment="Left" IsChecked="False" Margin="420,153,0,0" Name="Lab_Button" VerticalAlignment="Top" IsEnabled="False" Visibility="Hidden" />
        <Label Content="Select Store Type" Height="28" HorizontalAlignment="Left" Margin="18,109,0,0" Name="StrType_Label" VerticalAlignment="Top" Width="211" IsEnabled="False" Visibility="Hidden" />
        <RadioButton Content="SuperMarket" Height="16" HorizontalAlignment="Left" Margin="246,114,0,0" Name="SuperMkt_Button" VerticalAlignment="Top" IsChecked="True" GroupName="StrType" IsEnabled="False" Visibility="Hidden" />
        <RadioButton Content="GreenWise" Height="16" HorizontalAlignment="Left" Margin="345,114,0,0" Name="GreenWise_Button" VerticalAlignment="Top" GroupName="StrType" IsEnabled="False" Visibility="Hidden" />
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
    # Status Text for retail systems  
    #<TextBlock Height="96" HorizontalAlignment="Left" Margin="18,135,0,0" Name="Status_txt" Text="" VerticalAlignment="Top" Width="463" TextWrapping="Wrap" Background="White"></TextBlock>
    #<TextBlock Height="50" HorizontalAlignment="Left" Margin="12,249,0,0" Name="Status_txt" Text="" VerticalAlignment="Top" Width="312" TextWrapping="Wrap" />
    #Move the Status message text block
    $status_txt.Height=50;$status_txt.HorizontalAlignment="Left";$status_txt.Margin="12,249,0,0";$status_txt.VerticalAlignment="Top";$status_txt.Width="312"
    #Unhide and Enable the Retail controls
    $Lab_Button.Visibility="Visible";$Lab_Button.IsEnabled=$true
    $ISTSStaging_Button.Visibility="Visible";$ISTSStaging_Button.IsEnabled=$true
    $Store_Button.Visibility="Visible";$Store_Button.IsEnabled=$true
    $RBMLocation_Label.Visibility="Visible";$RBMLocation_Label.IsEnabled=$true
    $RBMSRV_combo.Visibility="Visible";$RBMSRV_combo.IsEnabled=$true
    $RBM_SRV_Label.Visibility="Visible";$RBM_SRV_Label.IsEnabled=$true
    $RBM_Label.Visibility="Visible";$RBM_Label.IsEnabled=$true
    $Dev_Button.Visibility="Visible";$Dev_Button.IsEnabled=$true
    $Test_button.Visibility="Visible";$Test_button.IsEnabled=$true
    $Stag_button.Visibility="Visible";$Stag_button.IsEnabled=$true
    $Prod_button.Visibility="Visible";$Prod_button.IsEnabled=$true
    $StrType_Label.Visibility="Visible";$StrType_Label.IsEnabled=$true
    $SuperMkt_Button.Visibility="Visible";$SuperMkt_Button.IsEnabled=$true
    $GreenWise_Button.Visibility="Visible";$GreenWise_Button.IsEnabled=$true
    
    #Computer name format validation
    $compname_txt.add_LostFocus({
        Switch -regex ($($compname_txt.Text.ToString()))
        {
            "[s]\d{8}\z"{
                $Continue_Button.IsEnabled = $true
                $status_txt.Text = ""
            }
            default{
                $compname_txt.Text = "Invalid Computer name!"
                $Continue_Button.IsEnabled = $false
                $status_txt.Text = 'Computer names must start with "S" then end with 8 digits. i.e. S12345678'
            }
        }
    })
    #location logic
    $Lab_Button.add_Checked({
        #Select DTO server and disable other locations; enable dev and test RBM enviroments
        $DTO.IsSelected = $true
        $script:PxRSBSServer = $RBMSRV_combo.SelectedValue.Content.ToString()
        $DTO.IsEnabled = $true
        $StagingCenter.IsEnabled = $false
        $Datacenter.IsEnabled = $false
        $Prod_button.IsEnabled = $true
        $Stag_button.IsEnabled = $true
        $Test_button.IsEnabled = $true
        $Dev_Button.IsEnabled = $true
    })
    $ISTSStaging_Button.add_Checked({
        #Select Staging Center Server and remove dev and test RBM enviroments
        $StagingCenter.IsSelected = $true
        $script:PxRSBSServer = $RBMSRV_combo.SelectedValue.Content.ToString()
        $DTO.IsEnabled = $false
        $StagingCenter.IsEnabled = $true
        $Datacenter.IsEnabled = $false
        $Prod_button.IsEnabled = $true
        $Stag_button.IsEnabled = $true
        $Test_button.IsEnabled = $false
        $Dev_Button.IsEnabled = $false
        if($Test_button.IsChecked){ $Prod_button.IsChecked = $true}
        if($Dev_Button.IsChecked){ $Prod_button.IsChecked = $true}
    })
    $Store_Button.add_Checked({
        #Select Data Center Server and remove dev and test RBM enviroments
        if($Stag_button.IsChecked){
            $StagingCenter.IsSelected = $true
            $StagingCenter.IsEnabled = $true
        }else{
            $Datacenter.IsSelected = $true
        }
        $script:PxRSBSServer = $RBMSRV_combo.SelectedValue.Content.ToString()
        $DTO.IsEnabled = $false
        $StagingCenter.IsEnabled = $false
        $Datacenter.IsEnabled = $true
        $Prod_button.IsEnabled = $true
        $Stag_button.IsEnabled = $true
        $Test_button.IsEnabled = $false
        $Dev_Button.IsEnabled = $false
        if($Test_button.IsChecked){ $Prod_button.IsChecked = $true}
        if($Dev_Button.IsChecked){ $Prod_button.IsChecked = $true}
    })
    #Set Default location to Store options
    $Datacenter.IsSelected = $true
    $DTO.IsEnabled = $false
    $StagingCenter.IsEnabled = $false
    $Datacenter.IsEnabled = $true
    $Prod_button.IsChecked = $true
    $Stag_button.IsEnabled = $true
    $Test_button.IsEnabled = $false
    $Dev_Button.IsEnabled = $false
    $script:PxRSBSServer = $RBMSRV_combo.SelectedValue.Content.ToString()
    $script:PxRSBSShare = "\\$PxRSBSServer\RSBS"
    $script:PxSourcePath = "\\$PxRSBSServer\Source"
    #RBM enviroment logic
    $Prod_button.add_Checked({
        if($Store_Button.IsChecked){
            $Datacenter.IsSelected = $true
            $Datacenter.IsEnabled = $true
            $StagingCenter.IsEnabled = $false
            $DTO.IsEnabled = $false
        }
        if($ISTSStaging_Button.IsChecked){
            $StagingCenter.IsSelected = $true
            $Datacenter.IsEnabled = $false
            $StagingCenter.IsEnabled = $true
            $DTO.IsEnabled = $false
        }
        if($Lab_Button.IsChecked){
            $DTO.IsSelected = $true
            $Datacenter.IsEnabled = $false
            $StagingCenter.IsEnabled = $false
            $DTO.IsEnabled = $true
        }
        $script:PxRSBSServer = $RBMSRV_combo.SelectedValue.Content.ToString()
        $script:PxRSBSShare = "\\$PxRSBSServer\RSBS"
        $script:PxSourcePath = "\\$PxRSBSServer\Source"
    })
    $Stag_button.add_Checked({
        if($Store_Button.IsChecked){
            $StagingCenter.IsSelected = $true
            $Datacenter.IsEnabled = $false
            $StagingCenter.IsEnabled = $true
            $DTO.IsEnabled = $false
        }
        if($ISTSStaging_Button.IsChecked){
            $StagingCenter.IsSelected = $true
            $Datacenter.IsEnabled = $false
            $StagingCenter.IsEnabled = $true
            $DTO.IsEnabled = $false
        }
        if($Lab_Button.IsChecked){
            $DTO.IsSelected = $true
            $Datacenter.IsEnabled = $false
            $StagingCenter.IsEnabled = $false
            $DTO.IsEnabled = $true
        }
        $script:PxRSBSServer = $RBMSRV_combo.SelectedValue.Content.ToString()
        $script:PxRSBSShare = "\\$PxRSBSServer\RSBS_STG"
        $script:PxSourcePath = "\\$PxRSBSServer\Source_STAGING"
    })
    $Test_button.add_Checked({
        $DTO.IsSelected = $true
        $Datacenter.IsEnabled = $false
        $StagingCenter.IsEnabled = $false
        $DTO.IsEnabled = $true
        $script:PxRSBSServer = $RBMSRV_combo.SelectedValue.Content.ToString()
        $script:PxRSBSShare = "\\$PxRSBSServer\RSBS_Test"
        $script:PxSourcePath = "\\$PxRSBSServer\Source_TEST"
    })
    $Dev_button.add_Checked({
        $DTO.IsSelected = $true
        $Datacenter.IsEnabled = $false
        $StagingCenter.IsEnabled = $false
        $DTO.IsEnabled = $true
        $script:PxRSBSServer = $RBMSRV_combo.SelectedValue.Content.ToString()
        $script:PxRSBSShare = "\\$PxRSBSServer\RSBS_DEV"
        $script:PxSourcePath = "\\$PxRSBSServer\Source_DEVELOPMENT"
    })
    #StoreType logic
    $SuperMkt_Button.add_Loaded({$Script:PxStoreType = "SuperMarket"})
    $SuperMkt_Button.add_Checked({$Script:PxStoreType = "SuperMarket"})
    $GreenWise_Button.add_Checked({$Script:PxStoreType = "GreenWise"})
    #RBMServer Selection Change
    $RBMSRV_combo.add_SelectionChanged({
        $script:PxRSBSServer = $RBMSRV_combo.SelectedValue.Content.ToString()
        $script:PxRSBSShare = $script:PxRSBSShare.Split("\")
        $script:PxRSBSShare = "\\$script:PxRSBSServer\$($script:PxRSBSShare[3].ToString())"
        $script:PxSourcePath = $script:PxSourcePath.Split("\")
        $script:PxSourcePath = "\\$script:PxRSBSServer\$($script:PxSourcePath[3].ToString())"
    })
}
if($Domain.ToUpper() -eq "RETAILSERVER")
{
	$PxOSDMenu.Height = 220
	$PublixLogo.Margin = "18,140,0,0"
	$Continue_Button.Margin = "345,145,0,0"
 	$Continue_Button.IsEnabled = $false #Disable the continue button until some validation is done 
    $status_txt.Height=50;$status_txt.HorizontalAlignment="Left";$status_txt.Margin="12,249,0,0";$status_txt.VerticalAlignment="Top";$status_txt.Width="312"
   
    $StrType_Label.Visibility="Visible";$StrType_Label.IsEnabled=$true
    $SuperMkt_Button.Visibility="Visible";$SuperMkt_Button.IsEnabled=$true
    $GreenWise_Button.Visibility="Visible";$GreenWise_Button.IsEnabled=$true
    
    #Computer name format validation
    $compname_txt.add_LostFocus({
        Switch -regex ($($compname_txt.Text.ToString()))
        {
            "[s]\d{8}\z"{
                $Continue_Button.IsEnabled = $true
                $status_txt.Text = ""
            }
            default{
                $compname_txt.Text = "Invalid Computer name!"
                $Continue_Button.IsEnabled = $false
                $status_txt.Text = 'Retail computer names must start with "S" than a 4 digit store number(XXXX) and end with a 4 digit machine type (YYYY). i.e. SXXXXYYYY = S99991234'
            }
        }
    })

    #StoreType logic
    $SuperMkt_Button.add_Loaded({$Script:PxStoreType = "SuperMarket"})
    $SuperMkt_Button.add_Checked({$Script:PxStoreType = "SuperMarket"})
    $GreenWise_Button.add_Checked({$Script:PxStoreType = "GreenWise"})

}
$compname_txt.Text = $OSDComputername
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
if($testing -eq $false){
    $tsenv.value("OSDComputername") = $computername
    $tsenv.value("OSDPxTimeZone") = $Tz_selection
    $tsenv.value("OSDPxEnvironment") = $PxLifecycle
    If($Domain.ToUpper() -eq "RETAIL"){
        $tsenv.value("OSDPxIsUScan") ="FALSE"
        $tsenv.value("OSDPxIsUScanAtt") ="FALSE"
        switch -Regex ($computername)
        {
            "[S]\d{4}\d[1][7][1-9]|[S]\d{4}\d[1][8][0]"{$tsenv.value("OSDPxIsUScan") ="TRUE"}
            "[S]\d{4}\d[1][7][1-2]"{$tsenv.value("OSDPxIsUScanAtt") ="TRUE"}
            "[S]\d{4}\d[1][9][0-9]"{$tsenv.value("OSDPxIsMobilePos") ="TRUE"}
        }
    $tsenv.value("OSDPxRSBSServer") = $PxRSBSServer
    $tsenv.value("OSDPxRSBSShare") = $PxRSBSShare
    $tsenv.value("OSDPxSourcePath") = $PxSourcePath
    $tsenv.value("OSDPxStoreType") = $PxStoreType
    }
    Write-Host " Computername set to $computername and OSDComputername set to $($tsenv.value("OSDComputername")) "
    Write-Host " Tz_selection set to $Tz_selection and OSDPxTimeZone set to $($tsenv.value("OSDPxTimeZone")) "
    Write-Host " PxLifecycle set to $PxLifecycle and OSDPxEnvironment set to $($tsenv.value("OSDPxEnvironment")) "
    Write-Host " OSDPxIsUScan set to $($tsenv.value("OSDPxIsUScan")) "
    Write-Host " OSDPxIsUScanAtt set to $($tsenv.value("OSDPxIsUScanAtt")) "
    Write-Host " OSDPxIsMobilePos set to $($tsenv.value("OSDPxIsMobilePos")) "
    Write-Host " PxRSBSServer set to $PxRSBSServer and OSDPxRSBSServer set to $($tsenv.value("OSDPxRSBSServer")) "
    Write-Host " PxRSBSShare set to $PxRSBSShare and OSDPxRSBSShare set to $($tsenv.value("OSDPxRSBSShare")) "
    Write-Host " PxSourcePath set to $PxSourcePath and OSDPxSourcePath set to $($tsenv.value("OSDPxSourcePath")) "
    Write-Host " PxStoreType set to $PxStoreType and OSDPxStoreType set to $($tsenv.value("OSDPxStoreType")) "
}else{
    $computername
    $Tz_selection
    $PxLifecycle
    If($Domain.ToUpper() -eq "RETAIL"){
        switch -Regex ($computername)
        {
            "[S]\d{4}\d[1][7][1-9]|[S]\d{4}\d[1][8][0]"{Write-Host "IsUScan"}
            "[S]\d{4}\d[1][7][1-2]"{Write-Host "IsUScanAtt"}
            "[S]\d{4}\d[1][9][0-9]"{Write-Host "IsMobilePOS"}
        }
    }
    If($PxRSBSServer){$PxRSBSServer}else{write-host "PxRSBSServer was not set"}
    If($PxRSBSShare){$PxRSBSShare}else{write-host "PxRSBSShare was not set"}
    If($PxSourcePath){$PxSourcePath}else{write-host "PxSourcePath was not set"}
    If($PxStoreType){$PxStoreType}else{write-host "PxStoreType was not set"}
}