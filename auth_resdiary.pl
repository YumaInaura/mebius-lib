
use Mebius::Newlist;
use Mebius::SNS::Diary;
use Mebius::History;
use Mebius::AllComments;
use Mebius::Query;

package main;
use strict;

#-----------------------------------------------------------
# SNS ���L�ւ̕ԐM
#-----------------------------------------------------------
sub auth_resdiary{

# �Ǐ���
my $all_comments = new Mebius::AllComments
my $sns_diary = new Mebius::SNS::Diary;
my($init_directory) = Mebius::BaseInitDirectory();
my($basic_init) = Mebius::basic_init();
my($my_account) = Mebius::my_account();
my $time = time;
my $history = new Mebius::History;
my $query = new Mebius::Query;
my $param  = $query->param();
my($line,$indexline,$pastline,$flag,$top1,$yearfile,$monthfile,$stop,$timeline,$i,$newcomment_handler,$maxres,$month_index_handler,$diary_index_handler,$subject,$myadmin_flag,%renew);
our($sub_title,$css_text,$head_link3,$head_link4,$head_link5,$date,%in,$lockkey,$title,$xip,$birdflag,$rcevil_flag,$thisyear,$thismonth,$today,$thishour,$thismin,$thissec);

my $comment_utf8 = utf8_return($param->{'comment'});
	if($all_comments->dupulication_error($comment_utf8)){
		auth_resdiary_error("�d�����e�ł��B");
	}


# ���X����̍ő吔
$maxres = 1000;

# �^�C�g����`
$sub_title = qq(���L�ւ̃��X | $title);

# CSS��`
$css_text .= qq(
.dtextarea{width:95%;height:300px;}
.alert{color:#f00;}
.please_text1{color:#080;font-size:120%;}
.wait{font-size:130%;color:#f00;}
div.error{line-height:1.4;padding:1em;border:solid 1px #f00;}
);

# ����������A����
my $maxmsg = 5000;
my $minmsg = 5;

# �G���[���̃t�b�N���e
#$fook_error = qq(���͓��e�F $in{'comment'});

# �A�N�Z�X����
&axscheck("ACCOUNT Post-only");

# �����`�F�b�N�P
my $account = $in{'account'};
$account =~ s/[^0-9a-z]//g;
	if($account eq ""){ &auth_resdiary_error("�f�[�^�w�肪�ςł��B"); }

# �����`�F�b�N�P
my $diary_number = $in{'num'};
$diary_number =~ s/\D//g;
	if($diary_number eq ""){ &auth_resdiary_error("�f�[�^�w�肪�ςł��B"); }

# �f�B���N�g����`
my($account_directory) = Mebius::Auth::account_directory($account);
	if(!$account_directory){ die("Perl Die! Account directory setting is empty."); }

	# ���O�C�����Ă��Ȃ��ꍇ
	if(!$my_account->{'login_flag'}){ &auth_resdiary_error("�R�����g����ɂ́A���O�C�����Ă��������B"); }

	# �`���[�W���ԃ`�F�b�N
	if($time < $main::myaccount{'next_comment_time'} && !$main::myaccount{'admin_flag'} && !Mebius::alocal_judge()){
		my($left_charge) = Mebius::SplitTime(undef, $main::myaccount{'next_comment_time'} - $main::time);
		&auth_resdiary_error("�`���[�W���Ԓ��ł��B���� $left_charge ���҂����������B");
	}

# �v���t�B�[�����J��
my(%account) = Mebius::Auth::File("Option File-check-error Key-check-error Lock-check-error",$account);

# �^�C�g������`
$head_link3 = qq(&gt; <a href="$basic_init->{'auth_url'}$account/">$account{'name'}</a> );
$head_link4 = qq(&gt; <a href="$basic_init->{'auth_url'}$account/diax-all-new">���L</a> );
$head_link5 = qq(&gt; ���X���e );

# ���݂��̃}�C���r��� / �֎~��Ԃ��`�F�b�N
my($friend_status1) = Mebius::Auth::FriendStatus("Deny-check-error",$account{'file'},$main::myaccount{'file'});
my($friend_status2) = Mebius::Auth::FriendStatus("Deny-check-error",$main::myaccount{'file'},$account{'file'});

	# �R�����g�ۂ𔻒�
	if($account{'let_flag'} && !$my_account->{'admin_flag'}){ &auth_resdiary_error("$account{'let_flag'}"); }
	if(!$account{'myprof_flag'} && !$my_account->{'admin_flag'}){
			if($account{'odiary'} eq "0"){ &auth_resdiary_error("�A�J�E���g��ȊO�̓R�����g�ł��܂���B"); }
			elsif($account{'odiary'} eq "2" && $friend_status1 ne "friend"){ &auth_resdiary_error("$main::friend_tag�ȊO�̓R�����g�ł��܂���B"); }
	}
	if($birdflag){ &auth_resdiary_error("�R�����g����ɂ͂��Ȃ��̕M����ݒ肵�Ă��������B"); }

# ���e���e�`�F�b�N
require "${init_directory}regist_allcheck.pl";

# ���̑҂����Ԃ𔻒�
Mebius::Regist::name_check($my_account->{'name'});
my($bglength,$smlength) = &get_length("",$in{'comment'});

	# �����`�F�b�N
	if($bglength > $maxmsg){ &auth_resdiary_error("�{���͑S�p$maxmsg�����ȓ��ɗ}���Ă��������B�i���� $bglength �����j"); }
	if($smlength < $minmsg && !Mebius::alocal_judge()){ &auth_resdiary_error("�{���͑S�p$minmsg�����ȏ�������Ă��������B�i���� $smlength �����j"); }

# �e��`�F�b�N
($in{'comment'}) = &all_check(undef,$in{'comment'});
&error_view("AERROR Target","auth_resdiary_error");

# �v���r���[
if($in{'preview'}){ &auth_resdiary_error(); }

# ���b�N�J�n
&lock("auth$account");

my($diary) = Mebius::Auth::diary( {} , $account,$diary_number);
	if(!$diary->{'f'}){
		main::error("���̓��L�͑��݂��܂���B");
	}

$renew{'+'}{'res'} = 1;
$renew{'lastrestime'} = time;
$renew{'last_handle'} = $my_account->{'name'};
$renew{'last_account'} = $my_account->{'id'};

my $newres = $diary->{'res'} + 1;

	# ���X���
	if($diary->{'res'} >= $maxres){ &auth_resdiary_error("���X����𒴂��Ă��܂��i$maxres���j�B"); }

	# �R�����g�ۂ̔���
	if(($diary->{'key'} eq "0" || $diary->{'key'} eq "2" || $diary->{'key'} eq "4") && !$my_account->{'admin_flag'}){
		&auth_resdiary_error("�R�����g�ł��܂���B���̓��L�͍폜�ς݁A�܂��̓��b�N���ł��B");
	}

	if($account{'myprof_flag'}){
		($renew{'owner_lastres_time'},$renew{'owner_lastres_number'}) = (time,$diary->{'res'}+1);
	}

# �ǉ�����s 
$line .= qq(1<>$newres<>$my_account->{'id'}<>$my_account->{'name'}<>$main::myaccount{'enctrip'}<>$main::myaccount{'encid'}<>$in{'comment'}<>$thisyear,$thismonth,$today,$thishour,$thismin,$thissec<>$main::myaccount{'color2'}<>$xip<>\n);

my($renewed_diary) = Mebius::Auth::diary({ Renew => 1 , push_line => $line } , $account,$diary_number , undef, \%renew);


# �A�J�E���g���̌��s�C���f�b�N�X���X�V
Mebius::SNS::Diary::index_file_per_account({ Renew => 1 , renew_line => { $diary_number => { res => $newres } } , file_type => "now" },$account);

# �����`�F�b�N�R
my $yearfile = $diary->{'year'};
my $monthfile = $diary->{'month'};
$yearfile =~ s/\D//g;
$monthfile =~ s/\D//g;

# �P�̃t�@�C���擾�����N/���f�[�^����t�@�C����`

	# �q�b�g�����ꍇ�̂݁A���ʃC���f�b�N�X���J��
	if($yearfile && $monthfile){
		Mebius::SNS::Diary::index_file_per_account({ Renew => 1 , renew_line => { $diary_number => { res => $newres } } , file_type => "month" },$account,$yearfile,$monthfile);
	}

# ����Ƀ��[���𑗐M
my %mail;
$mail{'url'} = "$account{'file'}/d-$diary_number#S$newres";
$mail{'comment'} = $main::in{'comment'};
$mail{'subject'} = qq($main::myaccount{'name'}���񂪁u$diary->{'subject'}�v�ɏ������݂܂����B);
Mebius::Auth::SendEmail(" Type-res-diary",\%account,\%main::myaccount,\%mail);

	# ����A�J�E���g�� �u�ŋ߂̍X�V�v�t�@�C�����X�V
	if(!$account{'myprof_flag'} || Mebius::alocal_judge()){
		Mebius::Auth::News("Renew Log-type-resdiary$diary_number",$account,$my_account->{'id'},$main::myaccount{'handle'},qq(<a href="$basic_init->{'auth_url'}$account/d-$diary_number#S$newres">$diary->{'subject'}</a> �ւ̃��X \(No.$newres\)));
	}


# �V�����X�ꗗ���X�V
&auth_renew_newres_diary("",$diary_number,$diary->{'subject'},$newres,%account);

	# ���ӓ��e�t�@�C�����X�V
	#if($main::a_com){
	#	Mebius::Auth::all_members_diary("Alert-res-file New-line Renew",$account,$diary_number,$diary->{'subject'},$in{'comment'},$my_account->{'name'},$newres);
	#}

# ���b�N����
&unlock("auth$account") if $lockkey;

	# �u���Ȃ��̃R�����g�����v���X�V
	if(!$account{'myprof_flag'} || Mebius::alocal_judge()){
		Mebius::SNS::Diary::comment_history("Renew New-res",$main::myaccount{'file'},$account,$diary_number,$newres);
	}

# �����̃I�v�V�����t�@�C�����X�V
my(%renew_myoption);
#$renew_myoption{'next_comment_time'} = $main::time + 60;
#Mebius::Auth::Optionfile("Renew",$main::myaccount{'file'},%renew_myoption);
$renew_myoption{'next_comment_time'} = time + 15;
Mebius::Auth::File("Renew Option",$main::myaccount{'file'},\%renew_myoption);

# ����̃A�J�E���g�E�I�v�V�����t�@�C�����X�V ( ���́H )
#Mebius::Auth::Optionfile("Renew",$account);
#Mebius::Auth::File("Renew Option",$account);

# �s���������X�V
#Mebius::Auth::History("Renew",$my_account->{'id'},$account,qq(�̓��L ( <a href="$basic_init->{'auth_url'}$account/d-${diary_number}#S$newres">$subject</a> ) �ɏ������݂܂����B));

# �����X�����X�V
Mebius::Newlist::Daily("Renew Resdiary-auth");

# ���X�Ď�
&rcevil($rcevil_flag,$in{'comment'},$my_account->{'name'},"$basic_init->{'auth_url'}$account/d-${diary_number}-$newres",$diary->{'subject'});

# �����̊�{���e�����t�@�C�����X�V
Mebius::HistoryAll("Renew My-file");

my $hidden_from_friends = $history->hidden_from_friends_judge_on_param();

my $subject_utf8 = utf8_return($diary->{'subject'});
my $handle_utf8 = utf8_return($my_account->{'name'});
$sns_diary->create_common_history({ content_targetA => $account , content_targetB => $diary_number , last_response_num => $newres , last_response_target => $newres , subject => $subject_utf8 , handle => $handle_utf8 , content_create_time => $diary->{'posttime'} });

$all_comments->submit_new_comment($comment_utf8);

# ���_�C���N�g
Mebius::Redirect("","$basic_init->{'auth_url'}$in{'account'}/d-$in{'num'}#S$newres");

# �I��
exit;


}

no strict;

#-----------------------------------------------------------
# �V�����X�ꗗ���X�V
#-----------------------------------------------------------
sub auth_renew_newres_diary{

# �Ǐ���
my($type,$open,$fook_sub,$newres,%account) = @_;
my($i,$iforeach,$line,$one_comment,$plus_lengths);
my($auth_log_directory) = Mebius::SNS::all_log_directory_path() || die;
my($my_account) = Mebius::my_account();

# �V�����X�ꗗ�̍ő�L�^��
my $max_newresdiary = 1000;

my $file = "${auth_log_directory}newresdiary.cgi";

# ���^�[������ꍇ
if($account{'osdiary'} eq "0" || $account{'osdiary'} eq "2"){ return; }

# �R�����g���P�s�����L�^
my($lengths,$iforeach);
foreach(split(/<br>/,$in{'comment'})){
$iforeach++;
$_ =~ s/( |�@)//g;
#if($iforeach >= 2){ $one_comment .= qq( / ); }
$plus_lengths += length($_);
$one_comment .= qq($_);
if($plus_lengths >= 2*100){ last; }
}

# �V���C���f�b�N�X���J��
my $line .= qq(1<>$open<>$fook_sub<>$account{'file'}<>$account{'name'}<>$my_account->{'id'}<>$my_account->{'name'}<>$one_comment<>$date<>$newres<>\n);
open(ALLRES_DIARY_IN,"<",$file);
	while(<ALLRES_DIARY_IN>){
		$i++;
			if($i < $max_newresdiary) { $line .= $_; }
	}
close(ALLRES_DIARY_IN);

# �V���C���f�b�N�X����������
Mebius::Fileout("",$file,$line);


}


#-----------------------------------------------------------
# �v���r���[
#-----------------------------------------------------------
sub auth_resdiary_error{

my($submit);
my($error) = @_;
my($init_directory) = Mebius::BaseInitDirectory();
our(%in,$lockflag);

require "${init_directory}auth_diary.pl";

	# �G���[���A�����b�N
	if($lockflag) { &unlock($lockflag); }

my $com_value = qq(\n$in{'comment'});
$com_value =~ s/<br>/\n/g;

	if($error ne ""){ $error = qq(<div class="error"><strong class="alert">�G���[�F</strong><br><br>$error</div><br><br>); }

# HTML
my $print = qq(
$error
<h1>�v���r���[</h1>
�܂��������܂�Ă��܂���B<br>
<h2>�v���r���[���e</h2>
<span style="color:#$main::myaccount{'color2'};">$in{'comment'}</span><br>
<h2>�C���t�H�[��</h2>);

$print .= auth_diary_response_form_core($in{'account'},$in{'num'},$com_value);

Mebius::Template::gzip_and_print_all({},$print);

exit;

}



1;
