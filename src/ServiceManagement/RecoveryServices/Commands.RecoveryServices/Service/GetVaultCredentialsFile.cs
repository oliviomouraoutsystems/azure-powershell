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

using System;
using System.Management.Automation;
using System.Security.Cryptography.X509Certificates;
using System.Threading.Tasks;
using Microsoft.Azure.Commands.RecoveryServices.SiteRecovery;
using Microsoft.Azure.Portal.HybridServicesCore;
using Microsoft.Azure.Portal.RecoveryServices.Models.Common;
using Microsoft.WindowsAzure.Commands.Common;
using Microsoft.WindowsAzure.Commands.Common.Models;
using Microsoft.WindowsAzure.Management.RecoveryServices.Models;
using Microsoft.WindowsAzure.Management.SiteRecovery.Models;

namespace Microsoft.Azure.Commands.RecoveryServices
{
    /// <summary>
    /// Retrieves Azure Site Recovery Server.
    /// </summary>
    [Cmdlet(VerbsCommon.Get, "AzureSiteRecoveryVaultCredential", DefaultParameterSetName = ASRParameterSets.Default)]
    [OutputType(typeof(string))]
    public class GetVaultCredentialsFile : RecoveryServicesCmdletBase
    {
        /// <summary>
        /// Expiry in hours for generated certificate.
        /// </summary>
        private const int VaultCertificateExpiryInHoursForHRM = 120;

        #region Parameters

        /// <summary>
        /// Gets or sets the vault name
        /// </summary>
        [Parameter(ParameterSetName = ASRParameterSets.ByParam, HelpMessage = "Vault Name for which the cred file to be generated")]
        [ValidateNotNullOrEmpty]
        public string Name { get; set; }

        /// <summary>
        /// Gets or sets the location of the vault
        /// </summary>
        [Parameter(ParameterSetName = ASRParameterSets.ByParam, HelpMessage = "Geo Location Name to which the vault belongs")]
        [ValidateNotNullOrEmpty]
        public string Location { get; set; }

        /// <summary>
        /// Gets or sets Job Object.
        /// </summary>
        [Parameter(ParameterSetName = ASRParameterSets.ByObject, Mandatory = true, ValueFromPipeline = true)]
        [ValidateNotNullOrEmpty]
        public ASRVault Vault { get; set; }

        /// <summary>
        /// Gets or sets the path where the credential file is to be generated
        /// </summary>
        [Parameter(ParameterSetName = ASRParameterSets.ByParam, Mandatory = false, HelpMessage = "The site name if the vault credentials to be downloaded for a Hyper-V sites.")]
        public string SiteName { get; set; }

        /// <summary>
        /// Gets or sets the path where the credential file is to be generated
        /// </summary>
        [Parameter(ParameterSetName = ASRParameterSets.ByParam, Mandatory = false, HelpMessage = "The path where the vault credential file is to be created.")]
        public string Path { get; set; }

        #endregion Parameters

        /// <summary>
        /// ProcessRecord of the command.
        /// </summary>
        public override void ExecuteCmdlet()
        {
            try
            {
                switch (this.ParameterSetName)
                {
                    case ASRParameterSets.ByObject:
                        this.Name = this.Vault.Name;
                        this.Location = this.Vault.Location;
                        this.GetByParams();
                        break;
                    case ASRParameterSets.ByParam:
                    default:
                        this.GetByParams();
                        break;
                }
            }
            catch (Exception exception)
            {
                this.HandleException(exception);
            }
        }

        /// <summary>
        /// Method to execute the command
        /// </summary>
        private async void GetByParams()
        {
            AzureSubscription subscription = AzureSession.CurrentContext.Subscription;

            CloudService cloudService = RecoveryServicesClient.GetCloudServiceForVault(this.Name, this.Location);
            string cloudServiceName = cloudService.Name;

            // Generate certificate
            X509Certificate2 cert = CertUtils.CreateSelfSignedCertificate(VaultCertificateExpiryInHoursForHRM, subscription.Id.ToString(), this.Name);

            Utilities.UpdateVaultSettings(new ASRVaultCreds()
            {
                CloudServiceName = cloudServiceName,
                ResourceName = this.Name
            });

            // Upload certificate
            UploadCertificateResponse acsDetails = await this.UpdateVaultCertificate(cert);

            // Get Channel Integrity key
            string channelIntegrityKey = await this.GetChannelIntegrityKey();

            // Generate file.
            ASRVaultCreds vaultCreds = this.GenerateCredential(
                subscription.Id.ToString(),
                this.Name,
                cert,
                acsDetails,
                channelIntegrityKey,
                cloudServiceName);

            string filePath = string.IsNullOrEmpty(this.Path) ? Utilities.GetDefaultPath() : this.Path;
            string fileName = this.GenerateFileName();

            // write the content to a file.
            Utilities.WriteToFile<ASRVaultCreds>(vaultCreds, filePath, fileName);
        }

        /// <summary>
        /// Method to update vault certificate
        /// </summary>
        /// <param name="cert">certificate object </param>
        /// <returns>Upload Certificate Response</returns>
        private async Task<UploadCertificateResponse> UpdateVaultCertificate(X509Certificate2 cert)
        {
            var certificateArgs = new CertificateArgs()
            {
                Certificate = Convert.ToBase64String(cert.GetRawCertData()),
                ContractVersion = "V2012_12"
            };

            UploadCertificateResponse response = await RecoveryServicesClient.UpdateVaultCertificate(certificateArgs);

            return response;
        }

        /// <summary>
        /// Get the Integrity key
        /// </summary>
        /// <returns>key as string.</returns>
        private async Task<string> GetChannelIntegrityKey()
        {
            ResourceExtendedInformation extendedInformation;
            try
            {
                extendedInformation = await RecoveryServicesClient.GetExtendedInfo();
            }
            catch (Exception)
            {
                // TODO:devsri - Handle specific error rather than generic once
                extendedInformation = new ResourceExtendedInformation();
            }

            ResourceExtendedInfo extendedInfo = Utilities.Deserialize<ResourceExtendedInfo>(extendedInformation.ExtendedInfo);

            if (extendedInfo == null)
            {
                ResourceExtendedInformationArgs extendedInfoArgs = extendedInfo.Translate();
                extendedInformation = await RecoveryServicesClient.CreateExtendedInfo(extendedInfoArgs);

                extendedInfo = Utilities.Deserialize<ResourceExtendedInfo>(extendedInformation.ExtendedInfo);
            }

            return extendedInfo.ChannelIntegrityKey;
        }

        /// <summary>
        /// Method to generate the credential file content
        /// </summary>
        /// <param name="subscriptionId">subscription id</param>
        /// <param name="resourceName">resource name</param>
        /// <param name="managementCert">management cert</param>
        /// <param name="acsDetails">ACS details</param>
        /// <param name="channelIntegrityKey">Integrity key</param>
        /// <param name="cloudServiceName">cloud service name</param>
        /// <returns>vault credential object</returns>
        private ASRVaultCreds GenerateCredential(string subscriptionId, string resourceName, X509Certificate2 managementCert, UploadCertificateResponse acsDetails, string channelIntegrityKey, string cloudServiceName)
        {
            string serializedCertifivate = Convert.ToBase64String(managementCert.Export(X509ContentType.Pfx));

            AcsNamespace acsNamespace = new AcsNamespace(acsDetails);

            ASRVaultCreds vaultCreds = new ASRVaultCreds(
                                            subscriptionId,
                                            resourceName,
                                            serializedCertifivate,
                                            acsNamespace,
                                            channelIntegrityKey,
                                            cloudServiceName);

            return vaultCreds;
        }

        /// <summary>
        /// Method to generate the file name
        /// </summary>
        /// <returns>file name as string.</returns>
        private string GenerateFileName()
        {
            string fileName;

            if (string.IsNullOrEmpty(this.SiteName))
            {
                fileName = string.Format("{0}_{1}.VaultCredentials", this.Name, DateTime.UtcNow.ToLongDateString());
            }
            else
            {
                fileName = string.Format("{0}_{1}_{2}.VaultCredentials", this.SiteName, this.Name, DateTime.UtcNow.ToLongDateString());
            }

            return fileName;
        }
    }
}
