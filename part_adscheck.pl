
use strict;
use Mebius::Fillter;

#-----------------------------------------------------------
# �L�����e�ɂ���čL���\���̗L���𔻒� - strict
#----------------------------------------------------------
sub adscheck{

# �錾
my($sub,$com) = @_;
my($flag);
our($nocview_flag,$noads_mode,$subtopic_mode,$alocal_mode);

	# �薼����
	if($sub eq "" && !$subtopic_mode){ $flag = 1; }

my($fillter_flag) = Mebius::Fillter::Ads({ FromEncoding => "sjis" },$sub,$com);
	if($fillter_flag){ $flag = 1; }

	# �{������
	if(length($com) < 2*10 && !$subtopic_mode){ $flag = 1; }

	if($flag){ $nocview_flag = 1; $noads_mode = 1; }

return($flag);

}

1;
