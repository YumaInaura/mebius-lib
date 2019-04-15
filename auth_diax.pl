
use Mebius::SNS;
package main;
use Mebius::Export;

#-------------------------------------------------
# ���ʃC���f�b�N�X�\��
#-------------------------------------------------
sub auth_diax{

my($basic_init) = Mebius::basic_init();

# �������[�h�ֈڍs
if($submode2 eq "all"){ require "${int_dir}auth_alldiary.pl"; &auth_alldiary(); }

# �Ǐ���
my($file,$link);

# �����`�F�b�N�P
$file = $in{'account'};
$file =~ s/[^0-9a-z]//g;

# �����`�F�b�N�Q
$openyear = $submode2;
$openyear =~ s/\D//g;

# �����`�F�b�N�R
$openmonth = $submode3;
$openmonth =~ s/\D//g;

# �v���t�B�[�����J��
&open($file);

# ���[�U�[�F�w��
if($ppcolor1){ $css_text .= qq(h2{background-color:#$ppcolor1;border-color:#$ppcolor1;}); }

# �}�C���r��Ԃ̎擾
&checkfriend($file);

	# ���L�\���̐���
	if($pplevel >= 1){
		if($pposdiary eq "2"){
				if(!$yetfriend && !$myprof_flag && !Mebius::SNS::admin_judge()){ &error("�C���f�b�N�X�����݂��܂���B"); }
					$text1 = qq(<em class="green">��$friend_tag�����ɓ��L���J���ł��B</em><br><br>);
					$onlyflag = 1;
				}
				elsif($pposdiary eq "0"){
						if(!$myprof_flag && !Mebius::SNS::admin_judge()){ &error("�C���f�b�N�X�����݂��܂���B"); }
					$text1 = qq(<em class="red">�����������ɓ��L���J���ł��B</em><br><br>);
					$onlyflag = 1;
				}
	}

# �C���f�b�N�X���擾
my($diary_index) = shift_jis(Mebius::SNS::Diary::view_index_per_account("month",$file,$openyear,$openmonth));
$diary_index = auth_diary_menu_round_form($file,$diary_index);

my($allindex) = auth_all_diary_month_index({ selected_year => $openyear , selected_month => $openmonth },$file);

# �M��
my $viewaccount = $ppfile;
if($ppname eq "none"){ $viewaccount = "****"; }

# �^�C�g����`
$sub_title = qq($openyear�N$openmonth���̓��L : $ppname - $viewaccount);

# �b�r�r��`
$css_text .= qq(
.lock{color:#070;}
h1{color:#080;}
);


$link = qq($adir$file/);

# �g�s�l�k
my $print = <<"EOM";
$footer_link
<h1>$openyear�N$openmonth���̓��L : $ppname - $viewaccount</h1>
$text1<a href="$link">$ppname - $viewaccount �̃v���t�B�[���ɖ߂�</a>
<h2 id="INDEX">���L�ꗗ</h2>
$diary_index
<h2>���ʈꗗ</h2>
$allindex
<br><br>
$footer_link2
EOM


Mebius::Template::gzip_and_print_all({},$print);

# �����I��
exit;

}

use strict;

#-----------------------------------------------------------
# ���L����p�̃t�H�[���ň͂�
#-----------------------------------------------------------
sub auth_diary_menu_round_form{

my($account,$diary_index) = @_;
my($basic_init) = Mebius::basic_init();

	if($diary_index && (Mebius::SNS::admin_judge() || Mebius::SNS::Diary::allow_user_revive_judge($account))){

		$diary_index = qq(
		<form method="post" method=").e($basic_init->{'auth_relative_url'}).qq("><input type="hidden" name="mode" value="skeditdiary">$diary_index<div class="margin"><input type="submit" value="��������s����"></div></form>
		);
	} else {
		0;
	}

$diary_index;

}

#-----------------------------------------------------------
# �S���L�̌��ʃC���f�b�N�X
#-----------------------------------------------------------
sub auth_all_diary_month_index{

my($use,$account) = @_;
my($allindex);
my($init_directory) = Mebius::BaseInitDirectory();
my($basic_init) = Mebius::basic_init();
my(@year);

	# �A�J�E���g������
	if(Mebius::Auth::AccountName(undef,$account)){ return(); }

# �f�B���N�g����`
my($account_directory) = Mebius::Auth::account_directory($account);
	if(!$account_directory){ die("Perl Die! Account directory setting is empty."); }

# �S�C���f�b�N�X��ǂݍ���
my $this_year;
open(ALL_INDEX_IN,"<","${account_directory}diary/${account}_diary_allindex.cgi");
	while(<ALL_INDEX_IN>){
		my($key,$year,$month) = split(/<>/,$_);
			if($this_year ne $year){
				$this_year = $year;
				$allindex .= "<b>${this_year}�N</b> ";
			}
			if($key){ $allindex .= qq(<a href="$basic_init->{'auth_url'}$account/diax-$year-$month">$month��</a> ); }
	}
close(ALL_INDEX_IN);

return($allindex);

}


1;
