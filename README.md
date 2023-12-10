# PublishZip
PowerShell scripts that I use to publish zip archives

The PowerShell script is executed in the .csproj file only during Publish.  See the **Exec** statement near the end.
``` XML
  <!-- Publish to Zip file -->
  <Target Name="PublishZip" AfterTargets="Publish">
    <PropertyGroup >
      <PowerShellScript>-File "D:\Visual Studio\Source\PowerShell\PublishZip\PubZipEx.ps1"</PowerShellScript>
      <Name>-name "[name of project]"</Name>
      <Version>-version $(AssemblyVersion)</Version>
      <Path>-path "$(ProjectDir)"</Path>
      <PublishFolder>-pubDir $(PublishDir)</PublishFolder>
    </PropertyGroup>

    <!-- This is the framework dependent version -->
    <PropertyGroup Condition="'$(PublishDir.Contains(`Framework_Dependent`))'">
      <PubType>-pubType ""</PubType>
    </PropertyGroup>

    <!-- This is the x64 self contained version-->
    <PropertyGroup Condition="'$(PublishDir.Contains(`Self_Contained_x64`))'">
      <PubType>-pubType SC_x64</PubType>
    </PropertyGroup>

    <!-- This is the x86 self contained version-->
    <PropertyGroup Condition="'$(PublishDir.Contains(`Self_Contained_x86`))'">
      <PubType>-pubType SC_x86</PubType>
    </PropertyGroup>

    <!-- Execute the PowerShell script -->
    <Exec Command="pwsh -NoProfile $(PowerShellScript) $(Name) $(Version) $(PubType) $(PublishFolder) $(Path)"/>
  </Target>
```
