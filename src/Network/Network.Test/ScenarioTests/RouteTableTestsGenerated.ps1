﻿# <auto-generated>
# Copyright (c) Microsoft and contributors.  All rights reserved.
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#   http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# 
# See the License for the specific language governing permissions and
# limitations under the License.
# 
# 
# Warning: This code was generated by a tool.
# 
# Changes to this file may cause incorrect behavior and will be lost if the
# code is regenerated.
# 
# For documentation on code generator please visit
#   https://aka.ms/nrp-code-generation
# Please contact wanrpdev@microsoft.com if you need to make changes to this file.
# </auto-generated>

function Check-CmdletReturnType
{
    param($cmdletName, $cmdletReturn)

    $cmdletData = Get-Command $cmdletName;
    Assert-NotNull $cmdletData;
    [array]$cmdletReturnTypes = $cmdletData.OutputType.Name | Foreach-Object { return ($_ -replace "Microsoft.Azure.Commands.Network.Models.","") };
    [array]$cmdletReturnTypes = $cmdletReturnTypes | Foreach-Object { return ($_ -replace "System.","") };
    $realReturnType = $cmdletReturn.GetType().Name -replace "Microsoft.Azure.Commands.Network.Models.","";
    return $cmdletReturnTypes -contains $realReturnType;
}

<#
.SYNOPSIS
Test creating new RouteTable using minimal set of parameters
#>
function Test-RouteTableCRUDMinimalParameters
{
    # Setup
    $rgname = Get-ResourceGroupName;
    $rglocation = Get-ProviderLocation ResourceManagement;
    $rname = Get-ResourceName;
    $location = Get-ProviderLocation "Microsoft.Network/routeTables";
    # Dependency parameters
    $RouteName = "RouteName";
    $RouteAddressPrefix = "10.0.0.0/8";

    try
    {
        $resourceGroup = New-AzResourceGroup -Name $rgname -Location $rglocation;

        # Create required dependencies
        $Route = New-AzRouteConfig -Name $RouteName -AddressPrefix $RouteAddressPrefix;

        # Create RouteTable
        $vRouteTable = New-AzRouteTable -ResourceGroupName $rgname -Name $rname -Location $location -Route $Route;
        Assert-NotNull $vRouteTable;
        Assert-True { Check-CmdletReturnType "New-AzRouteTable" $vRouteTable };
        Assert-NotNull $vRouteTable.Routes;
        Assert-True { $vRouteTable.Routes.Length -gt 0 };
        Assert-AreEqual $rname $vRouteTable.Name;

        # Get RouteTable
        $vRouteTable = Get-AzRouteTable -ResourceGroupName $rgname -Name $rname;
        Assert-NotNull $vRouteTable;
        Assert-True { Check-CmdletReturnType "Get-AzRouteTable" $vRouteTable };
        Assert-AreEqual $rname $vRouteTable.Name;

        # Get all RouteTables in resource group
        $listRouteTable = Get-AzRouteTable -ResourceGroupName $rgname;
        Assert-NotNull ($listRouteTable | Where-Object { $_.ResourceGroupName -eq $rgname -and $_.Name -eq $rname });

        # Get all RouteTables in subscription
        $listRouteTable = Get-AzRouteTable;
        Assert-NotNull ($listRouteTable | Where-Object { $_.ResourceGroupName -eq $rgname -and $_.Name -eq $rname });

        # Remove RouteTable
        $job = Remove-AzRouteTable -ResourceGroupName $rgname -Name $rname -PassThru -Force -AsJob;
        $job | Wait-Job;
        $removeRouteTable = $job | Receive-Job;
        Assert-AreEqual $true $removeRouteTable;

        # Get RouteTable should fail
        Assert-ThrowsContains { Get-AzRouteTable -ResourceGroupName $rgname -Name $rname } "not found";
    }
    finally
    {
        # Cleanup
        Clean-ResourceGroup $rgname;
    }
}

<#
.SYNOPSIS
Test creating new RouteTable
#>
function Test-RouteTableCRUDAllParameters
{
    # Setup
    $rgname = Get-ResourceGroupName;
    $rglocation = Get-ProviderLocation ResourceManagement;
    $rname = Get-ResourceName;
    $location = Get-ProviderLocation "Microsoft.Network/routeTables";
    # Resource's parameters
    $Tag = @{tag1='test'};
    # Resource's parameters for Set test
    $TagSet = @{tag2='testSet'};
    # Dependency parameters
    $RouteName = "RouteName";
    $RouteAddressPrefix = "10.0.0.0/8";

    try
    {
        $resourceGroup = New-AzResourceGroup -Name $rgname -Location $rglocation;

        # Create required dependencies
        $Route = New-AzRouteConfig -Name $RouteName -AddressPrefix $RouteAddressPrefix;

        # Create RouteTable
        $vRouteTable = New-AzRouteTable -ResourceGroupName $rgname -Name $rname -Location $location -Route $Route -Tag $Tag;
        Assert-NotNull $vRouteTable;
        Assert-True { Check-CmdletReturnType "New-AzRouteTable" $vRouteTable };
        Assert-NotNull $vRouteTable.Routes;
        Assert-True { $vRouteTable.Routes.Length -gt 0 };
        Assert-AreEqual $rname $vRouteTable.Name;
        Assert-AreEqualObjectProperties $Tag $vRouteTable.Tag;

        # Get RouteTable
        $vRouteTable = Get-AzRouteTable -ResourceGroupName $rgname -Name $rname;
        Assert-NotNull $vRouteTable;
        Assert-True { Check-CmdletReturnType "Get-AzRouteTable" $vRouteTable };
        Assert-AreEqual $rname $vRouteTable.Name;
        Assert-AreEqualObjectProperties $Tag $vRouteTable.Tag;

        # Get all RouteTables in resource group
        $listRouteTable = Get-AzRouteTable -ResourceGroupName $rgname;
        Assert-NotNull ($listRouteTable | Where-Object { $_.ResourceGroupName -eq $rgname -and $_.Name -eq $rname });

        # Get all RouteTables in subscription
        $listRouteTable = Get-AzRouteTable;
        Assert-NotNull ($listRouteTable | Where-Object { $_.ResourceGroupName -eq $rgname -and $_.Name -eq $rname });

        # Set RouteTable
        $vRouteTable.Tag = $TagSet;
        $vRouteTable = Set-AzRouteTable -RouteTable $vRouteTable;
        Assert-NotNull $vRouteTable;
        Assert-True { Check-CmdletReturnType "Set-AzRouteTable" $vRouteTable };
        Assert-AreEqual $rname $vRouteTable.Name;
        Assert-AreEqualObjectProperties $TagSet $vRouteTable.Tag;

        # Get RouteTable
        $vRouteTable = Get-AzRouteTable -ResourceGroupName $rgname -Name $rname;
        Assert-NotNull $vRouteTable;
        Assert-True { Check-CmdletReturnType "Get-AzRouteTable" $vRouteTable };
        Assert-AreEqual $rname $vRouteTable.Name;
        Assert-AreEqualObjectProperties $TagSet $vRouteTable.Tag;

        # Get all RouteTables in resource group
        $listRouteTable = Get-AzRouteTable -ResourceGroupName $rgname;
        Assert-NotNull ($listRouteTable | Where-Object { $_.ResourceGroupName -eq $rgname -and $_.Name -eq $rname });

        # Get all RouteTables in subscription
        $listRouteTable = Get-AzRouteTable;
        Assert-NotNull ($listRouteTable | Where-Object { $_.ResourceGroupName -eq $rgname -and $_.Name -eq $rname });

        # Remove RouteTable
        $job = Remove-AzRouteTable -ResourceGroupName $rgname -Name $rname -PassThru -Force -AsJob;
        $job | Wait-Job;
        $removeRouteTable = $job | Receive-Job;
        Assert-AreEqual $true $removeRouteTable;

        # Get RouteTable should fail
        Assert-ThrowsContains { Get-AzRouteTable -ResourceGroupName $rgname -Name $rname } "not found";

        # Set RouteTable should fail
        Assert-ThrowsContains { Set-AzRouteTable -RouteTable $vRouteTable } "not found";
    }
    finally
    {
        # Cleanup
        Clean-ResourceGroup $rgname;
    }
}

<#
.SYNOPSIS
Test creating new Route using minimal set of parameters
#>
function Test-RouteCRUDMinimalParameters
{
    # Setup
    $rgname = Get-ResourceGroupName;
    $rglocation = Get-ProviderLocation ResourceManagement;
    $rname = Get-ResourceName;
    $rnameAdd = "${rname}Add";
    $location = Get-ProviderLocation "Microsoft.Network/routeTables";
    # Resource's parameters
    $AddressPrefix = "10.0.0.0/8";
    # Resource's parameters for Set test
    $AddressPrefixSet = "11.0.0.0/8";
    # Resource's parameters for Add test
    $AddressPrefixAdd = "12.0.0.0/8";

    try
    {
        $resourceGroup = New-AzResourceGroup -Name $rgname -Location $rglocation;

        # Create Route
        $vRoute = New-AzRouteConfig -Name $rname -AddressPrefix $AddressPrefix;
        Assert-NotNull $vRoute;
        Assert-True { Check-CmdletReturnType "New-AzRouteConfig" $vRoute };
        $vRouteTable = New-AzRouteTable -ResourceGroupName $rgname -Name $rname -Route $vRoute -Location $location;
        Assert-NotNull $vRouteTable;
        Assert-AreEqual $rname $vRoute.Name;
        Assert-AreEqual $AddressPrefix $vRoute.AddressPrefix;

        # Get Route
        $vRoute = Get-AzRouteConfig -RouteTable $vRouteTable -Name $rname;
        Assert-NotNull $vRoute;
        Assert-True { Check-CmdletReturnType "Get-AzRouteConfig" $vRoute };
        Assert-AreEqual $rname $vRoute.Name;
        Assert-AreEqual $AddressPrefix $vRoute.AddressPrefix;

        # Get all RouteTable's Routes
        $listRoute = Get-AzRouteConfig -RouteTable $vRouteTable;
        Assert-NotNull ($listRoute | Where-Object { $_.Name -eq $rname });

        # Set Route
        $vRouteTable = Set-AzRouteConfig -Name $rname -RouteTable $vRouteTable -AddressPrefix $AddressPrefixSet;
        Assert-NotNull $vRouteTable;
        $vRouteTable = Set-AzRouteTable -RouteTable $vRouteTable;
        Assert-NotNull $vRouteTable;

        # Get Route
        $vRoute = Get-AzRouteConfig -RouteTable $vRouteTable -Name $rname;
        Assert-NotNull $vRoute;
        Assert-True { Check-CmdletReturnType "Get-AzRouteConfig" $vRoute };
        Assert-AreEqual $rname $vRoute.Name;
        Assert-AreEqual $AddressPrefixSet $vRoute.AddressPrefix;

        # Get all RouteTable's Routes
        $listRoute = Get-AzRouteConfig -RouteTable $vRouteTable;
        Assert-NotNull ($listRoute | Where-Object { $_.Name -eq $rname });

        # Add Route
        $vRouteTable = Add-AzRouteConfig -Name $rnameAdd -RouteTable $vRouteTable -AddressPrefix $AddressPrefixAdd;
        Assert-NotNull $vRouteTable;
        $vRouteTable = Set-AzRouteTable -RouteTable $vRouteTable;
        Assert-NotNull $vRouteTable;

        # Get Route
        $vRoute = Get-AzRouteConfig -RouteTable $vRouteTable -Name $rnameAdd;
        Assert-NotNull $vRoute;
        Assert-True { Check-CmdletReturnType "Get-AzRouteConfig" $vRoute };
        Assert-AreEqual $rnameAdd $vRoute.Name;
        Assert-AreEqual $AddressPrefixAdd $vRoute.AddressPrefix;

        # Get all RouteTable's Routes
        $listRoute = Get-AzRouteConfig -RouteTable $vRouteTable;
        Assert-NotNull ($listRoute | Where-Object { $_.Name -eq $rnameAdd });

        # Try Add again
        Assert-ThrowsContains { Add-AzRouteConfig -Name $rnameAdd -RouteTable $vRouteTable -AddressPrefix $AddressPrefixAdd } "already exists";

        # Remove Route
        $vRouteTable = Remove-AzRouteConfig -RouteTable $vRouteTable -Name $rnameAdd;
        $vRouteTable = Remove-AzRouteConfig -RouteTable $vRouteTable -Name $rname;
        # Additional call to test handling of already deleted subresource
        $vRouteTable = Remove-AzRouteConfig -RouteTable $vRouteTable -Name $rname;
        # Update parent resource
        $vRouteTable = Set-AzRouteTable -RouteTable $vRouteTable;
        Assert-NotNull $vRouteTable;

        # Get Route should fail
        Assert-ThrowsContains { Get-AzRouteConfig -RouteTable $vRouteTable -Name $rname } "Sequence contains no matching element";

        # Set Route should fail
        Assert-ThrowsContains { Set-AzRouteConfig -Name $rname -RouteTable $vRouteTable -AddressPrefix $AddressPrefixSet } "does not exist";
    }
    finally
    {
        # Cleanup
        Clean-ResourceGroup $rgname;
    }
}

<#
.SYNOPSIS
Test creating new Route
#>
function Test-RouteCRUDAllParameters
{
    # Setup
    $rgname = Get-ResourceGroupName;
    $rglocation = Get-ProviderLocation ResourceManagement;
    $rname = Get-ResourceName;
    $rnameAdd = "${rname}Add";
    $location = Get-ProviderLocation "Microsoft.Network/routeTables";
    # Resource's parameters
    $AddressPrefix = "10.0.0.0/8";
    $NextHopType = "VirtualNetworkGateway";
    # Resource's parameters for Set test
    $AddressPrefixSet = "11.0.0.0/8";
    $NextHopTypeSet = "VnetLocal";
    # Resource's parameters for Add test
    $AddressPrefixAdd = "12.0.0.0/8";
    $NextHopTypeAdd = "VnetLocal";

    try
    {
        $resourceGroup = New-AzResourceGroup -Name $rgname -Location $rglocation;

        # Create Route
        $vRoute = New-AzRouteConfig -Name $rname -AddressPrefix $AddressPrefix -NextHopType $NextHopType;
        Assert-NotNull $vRoute;
        Assert-True { Check-CmdletReturnType "New-AzRouteConfig" $vRoute };
        $vRouteTable = New-AzRouteTable -ResourceGroupName $rgname -Name $rname -Route $vRoute -Location $location;
        Assert-NotNull $vRouteTable;
        Assert-AreEqual $rname $vRoute.Name;
        Assert-AreEqual $AddressPrefix $vRoute.AddressPrefix;
        Assert-AreEqual $NextHopType $vRoute.NextHopType;

        # Get Route
        $vRoute = Get-AzRouteConfig -RouteTable $vRouteTable -Name $rname;
        Assert-NotNull $vRoute;
        Assert-True { Check-CmdletReturnType "Get-AzRouteConfig" $vRoute };
        Assert-AreEqual $rname $vRoute.Name;
        Assert-AreEqual $AddressPrefix $vRoute.AddressPrefix;
        Assert-AreEqual $NextHopType $vRoute.NextHopType;

        # Get all RouteTable's Routes
        $listRoute = Get-AzRouteConfig -RouteTable $vRouteTable;
        Assert-NotNull ($listRoute | Where-Object { $_.Name -eq $rname });

        # Set Route
        $vRouteTable = Set-AzRouteConfig -Name $rname -RouteTable $vRouteTable -AddressPrefix $AddressPrefixSet -NextHopType $NextHopTypeSet;
        Assert-NotNull $vRouteTable;
        $vRouteTable = Set-AzRouteTable -RouteTable $vRouteTable;
        Assert-NotNull $vRouteTable;

        # Get Route
        $vRoute = Get-AzRouteConfig -RouteTable $vRouteTable -Name $rname;
        Assert-NotNull $vRoute;
        Assert-True { Check-CmdletReturnType "Get-AzRouteConfig" $vRoute };
        Assert-AreEqual $rname $vRoute.Name;
        Assert-AreEqual $AddressPrefixSet $vRoute.AddressPrefix;
        Assert-AreEqual $NextHopTypeSet $vRoute.NextHopType;

        # Get all RouteTable's Routes
        $listRoute = Get-AzRouteConfig -RouteTable $vRouteTable;
        Assert-NotNull ($listRoute | Where-Object { $_.Name -eq $rname });

        # Add Route
        $vRouteTable = Add-AzRouteConfig -Name $rnameAdd -RouteTable $vRouteTable -AddressPrefix $AddressPrefixAdd -NextHopType $NextHopTypeAdd;
        Assert-NotNull $vRouteTable;
        $vRouteTable = Set-AzRouteTable -RouteTable $vRouteTable;
        Assert-NotNull $vRouteTable;

        # Get Route
        $vRoute = Get-AzRouteConfig -RouteTable $vRouteTable -Name $rnameAdd;
        Assert-NotNull $vRoute;
        Assert-True { Check-CmdletReturnType "Get-AzRouteConfig" $vRoute };
        Assert-AreEqual $rnameAdd $vRoute.Name;
        Assert-AreEqual $AddressPrefixAdd $vRoute.AddressPrefix;
        Assert-AreEqual $NextHopTypeAdd $vRoute.NextHopType;

        # Get all RouteTable's Routes
        $listRoute = Get-AzRouteConfig -RouteTable $vRouteTable;
        Assert-NotNull ($listRoute | Where-Object { $_.Name -eq $rnameAdd });

        # Try Add again
        Assert-ThrowsContains { Add-AzRouteConfig -Name $rnameAdd -RouteTable $vRouteTable -AddressPrefix $AddressPrefixAdd -NextHopType $NextHopTypeAdd } "already exists";

        # Remove Route
        $vRouteTable = Remove-AzRouteConfig -RouteTable $vRouteTable -Name $rnameAdd;
        $vRouteTable = Remove-AzRouteConfig -RouteTable $vRouteTable -Name $rname;
        # Additional call to test handling of already deleted subresource
        $vRouteTable = Remove-AzRouteConfig -RouteTable $vRouteTable -Name $rname;
        # Update parent resource
        $vRouteTable = Set-AzRouteTable -RouteTable $vRouteTable;
        Assert-NotNull $vRouteTable;

        # Get Route should fail
        Assert-ThrowsContains { Get-AzRouteConfig -RouteTable $vRouteTable -Name $rname } "Sequence contains no matching element";

        # Set Route should fail
        Assert-ThrowsContains { Set-AzRouteConfig -Name $rname -RouteTable $vRouteTable -AddressPrefix $AddressPrefixSet -NextHopType $NextHopTypeSet } "does not exist";
    }
    finally
    {
        # Cleanup
        Clean-ResourceGroup $rgname;
    }
}