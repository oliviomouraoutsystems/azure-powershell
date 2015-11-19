﻿// ----------------------------------------------------------------------------------
//
// Copyright Microsoft Corporation
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// http://www.apache.org/licenses/LICENSE-2.0
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// ----------------------------------------------------------------------------------

using Microsoft.Azure.Commands.AzureBackup.Properties;
using System;
using System.Management.Automation;

namespace Microsoft.Azure.Commands.AzureBackup.Cmdlets
{
    /// <summary>
    /// Command to remove an azure backup vault in the subscription
    /// </summary>
    [Cmdlet(VerbsCommon.Remove, "AzureRmBackupVault")]
    public class RemoveAzureRMBackupVault : AzureBackupVaultCmdletBase
    {
        [Parameter(Position = 1, Mandatory = false, HelpMessage = "Confirm deletion of vault")]
        public SwitchParameter Force { get; set; }

        protected override void ProcessRecord()
        {
            ExecutionBlock(() =>
            {
                base.ProcessRecord();

                ConfirmAction(Force, Resources.DeleteVaultCaption, Resources.DeleteVaultMessage, "",
                    () =>
                    {
                        if (!AzureBackupClient.DeleteVault(Vault.ResourceGroupName, Vault.Name))
                        {
                            throw new Exception(Resources.ResourceNotFoundMessage);
                        }
                    });
            });
        }
    }
}
