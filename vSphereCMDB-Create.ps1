############################################################################################
# Descripción:
# Secuencia de comandos de vSphere CMDB 2 de 5. Esta secuencia de comandos crea la base de datos en la instancia o el servidor SQL especificado.
# ¡IMPORTANTE! Si realiza algún cambio en las variables SQLInstance y SQLDatabase aquí, cámbielos también en los scripts 3,4,5.!
############################################################################################
# Requisitos:
# - Set-executionpolicy unrestricted en la computadora que ejecuta el script
# - Acceso a una instancia de servidor SQL con permisos suficientes para crear una base de datos vCMDB
############################################################################################
# Configure las siguientes variables para conectarse a la base de datos SQL
############################################################################################
$SQLInstance = ".\SQLEXPRESS"
$SQLDatabase = "vSphereCMDB"
############################################################################################
# No hay nada que cambiar debajo de esta línea, se proporcionan comentarios si necesita/quiere cambiar algo
############################################################################################
# Importación de las credenciales de SQL
############################################################################################
$SQLCredentials = IMPORT-CLIXML ".\SQLCredentials.xml"
$SQLUsername = $SQLCredentials.UserName
$SQLPassword = $SQLCredentials.GetNetworkCredential().Password
############################################################################################
# Comprobando si el módulo SqlServer ya está instalado, si no lo instalara
############################################################################################
$SQLModuleCheck = Get-Module -ListAvailable SqlServer
if ($null -eq $SQLModuleCheck)
{
write-host "SqlServer Module No Funciona - Instalando"
# No instalado
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
# Instalando el modulo
Install-Module -Name SqlServer -Scope AllUsers -Confirm:$false -AllowClobber
}
############################################################################################
# Importación del módulo SqlServer
############################################################################################
Import-Module SqlServer
############################################################################################
# Crear la base de datos de vSphere CMDB
############################################################################################
$SQLCreateDB = "USE master;  
GO  
CREATE DATABASE $SQLDatabase
GO"
invoke-sqlcmd -query $SQLCreateDB -ServerInstance $SQLInstance -Username $SQLUsername -Password $SQLPassword
############################################################################################
# Creación de una tabla SQL para Get-VM | select * + Get-VM | Get-VMGuest | select *
############################################################################################
# Name                    : ZVM3
# PowerState              : PoweredOff
# Notes                   : 
# Guest                   : ZVM3:
# NumCpu                  : 1
# CoresPerSocket          : 1
# MemoryMB                : 2048
# MemoryGB                : 2
# VMHostId                : HostSystem-host-121
# VMHost                  : 192.168.0.11
# VApp                    : 
# FolderId                : Folder-group-v555
# Folder                  : Templates
# ResourcePoolId          : ResourcePool-resgroup-134
# ResourcePool            : Resources
# HARestartPriority       : ClusterRestartPriority
# HAIsolationResponse     : AsSpecifiedByCluster
# DrsAutomationLevel      : AsSpecifiedByCluster
# VMSwapfilePolicy        : Inherit
# VMResourceConfiguration : CpuShares:Normal/1000 MemShares:Normal/20480
# Version                 : v8
# PersistentId            : 5034b549-e076-26d5-2918-b079317f7943
# GuestId                 : windows8Server64Guest
# UsedSpaceGB             : 18.127322494983673095703125
# ProvisionedSpaceGB      : 62.240105031058192253112792969
# DatastoreIdList         : {Datastore-datastore-217}
# ExtensionData           : VMware.Vim.VirtualMachine
# CustomFields            : {}
# Id                      : VirtualMachine-vm-177
# Uid                     : /VIServer=lab.local\administrator@192.168.0.61:443/VirtualMachine=VirtualMachine-vm-177/
# Client                  : VMware.VimAutomation.ViCore.Impl.V1.VimClient
# VM GUest info
# OSFullName        : Other 3.x or later Linux (64-bit)
# IPAddress         : {192.168.0.21, fe80::250:56ff:feb4:6c6e}
# State             : Running
# Disks             : {Capacity:2079145984, FreeSpace:1613664256, Path:/, Capacity:519917568, FreeSpace:448461824, Path:/mnt/run, Capacity:10433650688, FreeSpace:9557209088, Path:/mnt/logs}
# HostName          : Z-VRA-192-168-0-11
# Nics              : {Network adapter 1:Replication Traffic, :}
# ScreenDimensions  : {Width=720, Height=400}
# VmId              : VirtualMachine-vm-1419
# VM                : Z-VRA-192.168.0.11
# VmUid             : /VIServer=lab.local\administrator@192.168.0.61:443/VirtualMachine=VirtualMachine-vm-1419/
# VmName            : Z-VRA-192.168.0.11
# Uid               : /VIServer=lab.local\administrator@192.168.0.61:443/VirtualMachine=VirtualMachine-vm-1419/VMGuest=/
# GuestId           : other3xLinux64Guest
# ConfiguredGuestId : debian5_64Guest
# RuntimeGuestId    : other3xLinux64Guest
# ToolsVersion      : 
# ExtensionData     : VMware.Vim.GuestInfo
# Client            : VMware.VimAutomation.ViCore.Impl.V1.VimClient
# GuestFamily       : linuxGuest
$SQLCREATEVMs = "USE $SQLDatabase
    CREATE TABLE VMs (
    RecordID int IDENTITY(1,1) PRIMARY KEY,
	LastUpdated datetime,
    VMID varchar(50),
    Name varchar(255),
    PowerState varchar(20),
    Notes varchar(max),
    Guest varchar(255),
    NumCpu int,
    CoresPerSocket tinyint,
    MemoryGB int,
    VMHostId varchar(25),
    VMHost varchar(255),
    VApp varchar(255),
    FolderId varchar(255),
    Folder varchar(255),
    ResourcePoolId varchar(255),
    ResourcePool varchar(255),
    HARestartPriority varchar(50),
    HAIsolationResponse varchar(50),
    DrsAutomationLevel varchar(50),
    VMSwapfilePolicy varchar(50),
    VMResourceConfiguration varchar(50),
    Version varchar(10),
    UsedSpaceGB int,
    ProvisionedSpaceGB int,
    DatastoreIdList varchar(max),
    ExtensionData varchar(50),
    CustomFields varchar(255),
    Uid varchar(255),
    PersistentId varchar(50),
    OSFullName varchar(100),
    IPAddress varchar(max),
    State varchar(50),
    Hostname varchar(255),
    Nics varchar(max),
    GuestId varchar(255),
    RuntimeGuestId varchar(255),
    ToolsVersion varchar (100),
    ToolsVersionStatus varchar (100),
    GuestFamily varchar(255)
);"
invoke-sqlcmd -query $SQLCREATEVMs -ServerInstance $SQLInstance -Username $SQLUsername -Password $SQLPassword
############################################################################################
# Creación de una tabla SQL para Get-VM | Get-harddisk | select *
############################################################################################
# StorageFormat   : Thin
# Persistence     : Persistent
# DiskType        : Flat
# Filename        : [DC2SANVolume1] ZVM3/ZVM3_1.vmdk
# CapacityKB      : 20971520
# CapacityGB      : 20
# ParentId        : VirtualMachine-vm-177
# Parent          : ZVM3
# Uid             : /VIServer=lab.local\administrator@192.168.0.61:443/VirtualMachine=VirtualMachine-vm-177/HardDisk=2001/
# ConnectionState : 
# ExtensionData   : VMware.Vim.VirtualDisk
# Id              : VirtualMachine-vm-177/2001
# Name            : Hard disk 2
# Client          : VMware.VimAutomation.ViCore.Impl.V1.VimClient
$SQLCREATEVMDisks = "USE $SQLDatabase
    CREATE TABLE VMDisks (
    RecordID int IDENTITY(1,1) PRIMARY KEY,
	LastUpdated datetime, 
    VMID varchar(255),
    Parent varchar(255),
    DiskID varchar(100),
    Name varchar(100),
    Filename varchar(max),
    CapacityGB int,
    Persistence varchar(25),
    DiskType varchar(25),
    StorageFormat varchar(25)
);"
invoke-sqlcmd -query $SQLCREATEVMDisks -ServerInstance $SQLInstance -Username $SQLUsername -Password $SQLPassword
############################################################################################
# Creación de una tabla SQL para Get-View -ViewType VirtualMachine To Get Disk Info
############################################################################################
# VMID            : VirtualMachine-vm-1096
# Name            : VPNServer2017
# DiskNum         : 0
# DiskPath        : C:\
# DiskCapacityGB  : 40
# DiskFreeSpaceGB : 26
# DiskCapacityMB  : 40458
# DiskFreeSpaceMB : 26381
$SQLCREATEVMDiskUsage = "USE $SQLDatabase
    CREATE TABLE VMDiskUsage (
    RecordID int IDENTITY(1,1) PRIMARY KEY,
	LastUpdated datetime, 
    VMID varchar(255),
    Name varchar(255),
    DiskNum int,
    DiskPath varchar(255),
    DiskCapacityGB int,
    DiskFreeSpaceGB int,
    DiskCapacityMB int,
    DiskFreeSpaceMB int
);"
invoke-sqlcmd -query $SQLCREATEVMDiskUsage -ServerInstance $SQLInstance -Username $SQLUsername -Password $SQLPassword
############################################################################################
# Creación de una tabla SQL para for Get-VM | Get-networkadapter | select *
############################################################################################
# MacAddress       : 00:50:56:b4:bf:9f
# WakeOnLanEnabled : True
# NetworkName      : VM Network
# Type             : Vmxnet3
# ParentId         : VirtualMachine-vm-177
# Parent           : ZVM3
# Uid              : /VIServer=lab.local\administrator@192.168.0.61:443/VirtualMachine=VirtualMachine-vm-177/NetworkAdapter=4000/
# ConnectionState  : NotConnected, GuestControl, StartConnected
# ExtensionData    : VMware.Vim.VirtualVmxnet3
# Id               : VirtualMachine-vm-177/4000
# Name             : Network adapter 1
# Client           : VMware.VimAutomation.ViCore.Impl.V1.VimClient
$SQLCREATEVMNICs = "USE $SQLDatabase
    CREATE TABLE VMNICs (
    RecordID int IDENTITY(1,1) PRIMARY KEY,
    LastUpdated datetime,
	VMID varchar(255),
    Parent varchar(255),
    NICID varchar (100),
    Name varchar(100),
    MacAddress varchar(17),
    NetworkName varchar(255),
    ConnectionState varchar(255),
    WakeOnLanEnabled varchar(10),
    Type varchar(25)
);"
invoke-sqlcmd -query $SQLCREATEVMNICs -ServerInstance $SQLInstance -Username $SQLUsername -Password $SQLPassword
############################################################################################
# Creación de una tabla SQL para Get-datastore | select *
############################################################################################
# FileSystemVersion              : 5.81
# DatacenterId                   : Datacenter-datacenter-2
# Datacenter                     : Datacenter1
# ParentFolderId                 : Folder-group-s5
# ParentFolder                   : datastore
# DatastoreBrowserPath           : vmstores:\192.168.0.61@443\Datacenter1\ESXi3SSD
# FreeSpaceMB                    : 229515
# CapacityMB                     : 236544
# Accessible                     : True
# Type                           : VMFS
# StorageIOControlEnabled        : False
# CongestionThresholdMillisecond : 30
# State                          : Available
# ExtensionData                  : VMware.Vim.Datastore
# CapacityGB                     : 231
# FreeSpaceGB                    : 224.1357421875
# Name                           : ESXi3SSD
# Id                             : Datastore-datastore-2146
# Uid                            : /VIServer=lab.local\administrator@192.168.0.61:443/Datastore=Datastore-datastore-2146/
# Client                         : VMware.VimAutomation.ViCore.Impl.V1.VimClient
$SQLCREATEDatastores = "USE $SQLDatabase
    CREATE TABLE Datastores (
    RecordID int IDENTITY(1,1) PRIMARY KEY,
	LastUpdated datetime, 
    DatastoreID varchar(100),
    Name varchar(255),
    CapacityGB int,
    FreeSpaceGB int,
    State varchar(25),
    Type varchar(25),
    FileSystemVersion int,
    Accessible varchar(25),
    StorageIOControlEnabled varchar(25),
    CongestionThresholdMillisecond int,
    ParentFolderId varchar(100),
    ParentFolder varchar(100),
    DatacenterId varchar(100),
    Datacenter varchar(100),
    Uid varchar(255)
);"
invoke-sqlcmd -query $SQLCREATEDatastores -ServerInstance $SQLInstance -Username $SQLUsername -Password $SQLPassword
############################################################################################
# Creación de una tabla SQL para Get-virtualportgroup | select *
############################################################################################
# Name              : iSCSI1
# VirtualSwitchId   : key-vim.host.VirtualSwitch-vSwitch0
# VirtualSwitchUid  : /VIServer=lab.local\administrator@192.168.0.61:443/VMHost=HostSystem-host-121/VirtualSwitch=key-vim.host.VirtualSwitch-vSwitch0/
# VirtualSwitch     : vSwitch0
# Key               : key-vim.host.PortGroup-iSCSI1
# Port              : {host}
# VLanId            : 0
# VirtualSwitchName : vSwitch0
# VMHostId          : HostSystem-host-121
# VMHostUid         : /VIServer=lab.local\administrator@192.168.0.61:443/VMHost=HostSystem-host-121/
# Uid               : /VIServer=lab.local\administrator@192.168.0.61:443/VMHost=HostSystem-host-121/VirtualSwitch=key-vim.host.VirtualSwitch-vSwitch0/VirtualPortGroup=key-vim.host.PortGroup-iSCSI1/
# ExtensionData     : VMware.Vim.HostPortGroup
# Client            : VMware.VimAutomation.ViCore.Impl.V1.VimClient
$SQLCREATEPortGroups = "USE $SQLDatabase
    CREATE TABLE PortGroups (
    RecordID int IDENTITY(1,1) PRIMARY KEY,
    LastUpdated datetime, 
	VirtualSwitchId varchar(100),
    Name varchar(100),
    VirtualSwitch varchar(100),
    VirtualSwitchName varchar(100),
    PortGroupKey varchar(100),
    VLanId int,
    VMHostId varchar(100),
    VMHostUid varchar(255),
    Uid varchar(255)
);"
invoke-sqlcmd -query $SQLCREATEPortGroups -ServerInstance $SQLInstance -Username $SQLUsername -Password $SQLPassword
############################################################################################
# Creación de una tabla SQL para Get-vmhost | select *
############################################################################################
# State                 : Connected
# ConnectionState       : Connected
# PowerState            : PoweredOn
# VMSwapfileDatastoreId : 
# VMSwapfilePolicy      : Inherit
# ParentId              : ClusterComputeResource-domain-c133
# IsStandalone          : False
# Manufacturer          : To Be Filled By O.E.M.
# Model                 : To Be Filled By O.E.M.
# NumCpu                : 8
# CpuTotalMhz           : 19192
# CpuUsageMhz           : 3570
# LicenseKey            : YM481-4YKE0-J898T-059H0-25QH4
# MemoryTotalMB         : 32740.92578125
# MemoryTotalGB         : 31.973560333251953125
# MemoryUsageMB         : 7074
# MemoryUsageGB         : 6.908203125
# ProcessorType         : Intel(R) Atom(TM) CPU  C2750  @ 2.40GHz
# HyperthreadingActive  : False
# TimeZone              : UTC
# Version               : 6.5.0
# Build                 : 4564106
# Parent                : ProdCluster1
# VMSwapfileDatastore   : 
# StorageInfo           : HostStorageSystem-storageSystem-121
# NetworkInfo           : 192:168.0.11
# DiagnosticPartition   : 
# FirewallDefaultPolicy : VMHostFirewallDefaultPolicy:HostSystem-host-121
# ApiVersion            : 6.5
# MaxEVCMode            : intel-westmere
# Name                  : 192.168.0.11
# CustomFields          : {[AutoDeploy.MachineIdentity, ]}
# ExtensionData         : VMware.Vim.HostSystem
# Id                    : HostSystem-host-121
# Uid                   : /VIServer=lab.local\administrator@192.168.0.61:443/VMHost=HostSystem-host-121/
# Client                : VMware.VimAutomation.ViCore.Impl.V1.VimClient
# DatastoreIdList       : {Datastore-datastore-163, Datastore-datastore-164, Datastore-datastore-217, Datastore-datastore-218...}
$SQLCREATEHosts = "USE $SQLDatabase
    CREATE TABLE Hosts (
    RecordID int IDENTITY(1,1) PRIMARY KEY,
	LastUpdated datetime, 
    HostID varchar(100),
    Name varchar(255),
    VMs int,
    VMDisks int,
    VMNICs int,
    Datastores int,
    PortGroups int,
    State varchar(50),
    ConnectionState varchar(100),
    PowerState varchar(100),
    NumCpu int,
    CpuTotalMhz int,
    CpuUsageMhz int,
    MemoryTotalGB int,
    MemoryUsageGB int,
    ProcessorType varchar(100),
    HyperthreadingActive varchar(100),
    TimeZone varchar(25),
    Version int,
    Build int,
    Parent varchar(100),
    IsStandalone varchar(20),
    VMSwapfileDatastore varchar(255),
    StorageInfo varchar(100),
    NetworkInfo int,
    DiagnosticPartition varchar(100),
    FirewallDefaultPolicy varchar(100),
    ApiVersion int,
    MaxEVCMode varchar(100),
    Manufacturer varchar(255),
    Model varchar(255),
    Uid varchar(255),
    DatastoreIdList varchar(255)
);"
invoke-sqlcmd -query $SQLCREATEHosts -ServerInstance $SQLInstance -Username $SQLUsername -Password $SQLPassword
############################################################################################
# Creación de una tabla SQL para Get-cluster | select *
############################################################################################
# VsanEnabled               : False
# VsanDiskClaimMode         : Manual
# HATotalSlots              : 
# HAUsedSlots               : 
# HAAvailableSlots          : 
# HASlotCpuMHz              : 
# HASlotMemoryMb            : 
# HASlotMemoryGB            : 
# HASlotNumVCpus            : 
# ParentId                  : Folder-group-h4
# ParentFolder              : host
# HAEnabled                 : False
# HAAdmissionControlEnabled : True
# HAFailoverLevel           : 1
# HARestartPriority         : Medium
# HAIsolationResponse       : DoNothing
# VMSwapfilePolicy          : WithVM
# DrsEnabled                : False
# DrsMode                   : FullyAutomated
# DrsAutomationLevel        : FullyAutomated
# EVCMode                   : 
# Name                      : ProdCluster1
# CustomFields              : {}
# ExtensionData             : VMware.Vim.ClusterComputeResource
# Id                        : ClusterComputeResource-domain-c133
# Uid                       : /VIServer=lab.local\administrator@192.168.0.61:443/Cluster=ClusterComputeResource-domain-c133/
# Client                    : VMware.VimAutomation.ViCore.Impl.V1.VimClient
$SQLCREATEClusters = "USE $SQLDatabase
    CREATE TABLE Clusters (
    RecordID int IDENTITY(1,1) PRIMARY KEY,
	LastUpdated datetime,
    ClusterID varchar(100),
    Name varchar(100),
    Hosts int,
    VMs int,
    VMDisks int,
    VMNICs int,
    Datastores int,
    DrsEnabled varchar(100),
    DrsMode varchar(100),
    DrsAutomationLevel varchar(100),
    HAEnabled varchar(100),
    HAAdmissionControlEnabled varchar(100),
    HAFailoverLevel int,
    HARestartPriority varchar(100),
    HAIsolationResponse varchar(100),
    HATotalSlots int,
    HAUsedSlots int,
    HAAvailableSlots int,
    HASlotCpuMHz int,
    HASlotMemoryGB int,
    HASlotNumVCpus int,
    ParentId varchar(100),
    ParentFolder varchar(100),
    VMSwapfilePolicy varchar(100),
    VsanEnabled varchar(100),
    VsanDiskClaimMode varchar(100),
    EVCMode varchar(100),
    CustomFields varchar(MAX),
    Uid varchar(255)
);"
invoke-sqlcmd -query $SQLCREATEClusters -ServerInstance $SQLInstance -Username $SQLUsername -Password $SQLPassword
############################################################################################
# Creación de una tabla SQL para Get-datacenter | select *
############################################################################################
# ParentFolderId    : Folder-group-d1
# ParentFolder      : Datacenters
# Name              : Datacenter1
# CustomFields      : {}
# ExtensionData     : VMware.Vim.Datacenter
# Id                : Datacenter-datacenter-2
# Uid               : /VIServer=lab.local\administrator@192.168.0.61:443/Datacenter=Datacenter-datacenter-2/
# Client            : VMware.VimAutomation.ViCore.Impl.V1.VimClient
# DatastoreFolderId : Folder-group-s5
$SQLCREATEDatacenters = "USE $SQLDatabase
    CREATE TABLE Datacenters (
    RecordID int IDENTITY(1,1) PRIMARY KEY,
	LastUpdated datetime,
    DatacenterID varchar(100),
    Name varchar(100),
    Clusters int,
    Hosts int,
    VMs int,
    VMDisks int,
    VMNICs int,
    Datastores int,
    PortGroups int,
    CustomFields varchar(max),
    ParentFolderId varchar(100),
    ParentFolder varchar(100),
    Uid varchar(255),
    DatastoreFolderId varchar (255)
);"
invoke-sqlcmd -query $SQLCREATEDatacenters -ServerInstance $SQLInstance -Username $SQLUsername -Password $SQLPassword
############################################################################################
# Fin del script
############################################################################################