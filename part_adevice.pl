#-----------------------------------------------------------
# ÇtÇ`Ç©ÇÁîªíË
#-----------------------------------------------------------

sub do_adevice{

# ã«èäâª
my($file) = @_;
my($adevice_type,$select_dir,$k_access,$kaccess_one);

# ÇtÇ`Ç©ÇÁ $k_access ÇîªíË
if($file =~ /(^DoCoMo)/){ $k_access = "DOCOMO"; }
if($file =~ /(^KDDI|^UP\.Browser)/){ $k_access = "AU"; }
if($file =~ /(^SoftBank|^Vodafone|^J-PHONE)/){ $k_access = "SOFTBANK"; }

# KACCESS_ONE
if($file =~ /^DoCoMo([a-zA-Z0-9 ;\(\/\.]+?);ser([0-9a-z]{15});/){
$k_access = "DOCOMO";
$kaccess_one = $2;
}

if($file =~ /^([0-9]+)_([a-z]+)\.ezweb\.ne\.jp$/){
$kaccess_one = "${1}_${2}";
$k_access="AU";
}

if($file =~ /\/SN([0-9]+)/){
$kaccess_one = $1;
$k_access="SOFTBANK";
}

if($kaccess_one){ $adevice_type = "kaccess_one"; $select_dir = "_data_kaccess_one/"; }
elsif($file =~ /^([a-zA-Z0-9\.\-]+)\.([a-z]{2,3})$/ || $file eq "localhost"){ $adevice_type = "host"; $select_dir = "_data_host/"; }
elsif($file =~ /^([a-zA-Z0-9]+)$/){ $adevice_type = "number"; $select_dir = "_data_number/"; }
else{ $adevice_type = "agent"; $select_dir = "_data_agent/"; }

return($adevice_type,$select_dir,$k_access,$kaccess_one);

}


1;
