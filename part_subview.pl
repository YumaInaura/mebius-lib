
use strict;
package main;

#-----------------------------------------------------------
# �T�u�L�����[�h�̊�{�ݒ�
#-----------------------------------------------------------
sub init_option_bbs_subbase{


my($init_directory) = Mebius::BaseInitDirectory();
our($moto);

	our $subtopic_link = undef;
	our $subtopic_mode = 1;
	our $style = '/style/sub1.css';
}

#-----------------------------------------------------------
# �T�u�L�� ��{����
#-----------------------------------------------------------
sub thread_sub_base{

my($MAIN_FILE,$SUB_FILE);
my($init_directory) = Mebius::BaseInitDirectory();
our(%in,$xclose,$moto,$kflag);

# �e���`
#$nomemo_flag = 1;
our $concept .= qq( NOT-KR);
our $resedit_mode = 0;

# CSS��`
our $css_text .= qq(
textarea{background-color:#f2f2ff;border:solid 1px #99b;}
li{line-height:2.0em;}
.bbs_border{border-style:groove;border-width:1px;}
);

# ���C���L����ǂݍ���
my($main_thread) = Mebius::BBS::thread_state({ Auto => 1 , MainThread => 1 },$in{'no'});
our($no,$sub,$mainres,$key,$res_pwd,$t_res,$d_delman,$d_password,$dd1,$sexvio,$dd3,$dd4,$dd5,$dd6,$dd7,$dd8,$juufuku_com,$dd10) = split(/<>/,$main_thread->{'all_line'}->[0]);
	if(!$main_thread->{'f'}){ http404(); }

my $bbs_path = Mebius::BBS::Path->new($main_thread);
my $thread_url = $bbs_path->thread_url_adjusted();

our $mainsub = $sub;
our $sub = "$sub [ �T�u ]";

# �L���f�[�^�ǂݍ���
my($sub_thread) = Mebius::BBS::thread_state({ Auto => 1 , SubThread => 1 },$in{'no'});
our($subno,$subsub,$res,$subkey,$subres_pwd,$t_res,undef,$subd_password,$subdd1,$subsexvio,$subdd3,$subdd4,$subdd5,$subdd6,$subdd7,$subdd8,$juufuku_com,$subdd10) = split(/<>/, $sub_thread->{'all_line'}->[0]);

	# ���X���Ȃ��ꍇ�L���������A404�G���[
	if($res <= 0){ our $noads_mode = 1; our $noindex_flag = 1; } # &http404();

	# �ߋ����O�ŁA�T�u�L���̃��X�������ꍇ
	if($key eq "3" && !$res){ &error("���̃T�u�L���͉ߋ����O�ŁA���X������܂���B"); }

	# ���C���L���ւ̃����N
	if(!$mainres){ $mainres = 0; }
our $move_mainres = qq(<span class="comoji">�ؑցF <a href="$thread_url" class="red">���C���L��</a> <a href="$thread_url#S$mainres" class="red">($mainres)</a> / <span class="green">�T�u�L��($res)</span></span> ) if($mainres);

# �ŐV�̏�������
my($lastres_link);
	if($in{'r'} eq "" && $in{'No'} eq "" && $res >= 1){ $lastres_link = qq( - <a href="#S${res}">���ŏI���X($res)</a>); }

	# �^�C�g����`
	if($kflag){
		require "${init_directory}k_view.pl";
		thread_set_title_mobile();
	}
	else{
		thread_set_title({ SubThread => 1 },$main_thread);
	}

$main_thread,$sub_thread;

}


#-----------------------------------------------------------
# No.0 �̕\�����e
#-----------------------------------------------------------
sub thread_get_subzero{

my($line);
my $use_thread = shift;
our($mainres,%in,$moto,$sub,$ads_up,$ads_rup,$mainsub,$res,$guide_url,$lastres_link);
my $bbs_path = Mebius::BBS::Path->new($use_thread);
my $thread_url = $bbs_path->thread_url_adjusted({ MainThread => 1 });

$line = qq(
<div class="d"> 
<strong><span class="vsub">$sub </span> </strong> 
<a href="$thread_url" class="red">�����C���L��</a> <a href="$thread_url#S$mainres" class="red">($mainres)</a> / <span class="green">���T�u�L��($res)</span>);

my($request_url_encoded) = Mebius::request_url_encoded();

$line .= qq(
$lastres_link
<br><br>
<ul style="margin-bottom:1.5em;">
<li><a href="/_$moto/$in{'no'}.html">$mainsub</a> �̃T�u�L���ł��B���z�A�R�����g�Ȃǂɂ����p���������B
<li><strong class="red">���C���L���ƑS���֌W�̂Ȃ��G�k</strong>�͂��������������B
<li><a href="${guide_url}%A5%B5%A5%D6%B5%AD%BB%F6%A3%D1%A1%F5%A3%C1">���A�ڂ����g�������̓T�u�L���K�C�h���������������B</a>
</ul>
$ads_up$ads_rup
<br class="clear">
</div>
);

return($line);

}


#-----------------------------------------------------------
# No.0 �̕\�����e �i�g�єŁj
#-----------------------------------------------------------
sub thread_get_ksubzero{

my($line);
our($xclose,$moto,%in,$mainsub,$ktext_up);

$line = qq(<hr$xclose><a name="S0" id="S0"></a>����́h<a href="/_$moto/$in{'no'}.html">$mainsub</a>�h�̃T�u�L���ł��B$ktext_up);

return($line);


}



1;
