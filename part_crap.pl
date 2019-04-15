
use Mebius::History;
use Mebius::BBS::Crap;
use Mebius::BBS::Thread;
package main;
use Mebius::Export;

#-----------------------------------------------------------
# �L���̂����ˁI - no strict;
#-----------------------------------------------------------
sub bbs_support{

our(%in);

	# �g�уt���O
	if($mode eq "kview" || $in{'k'}){ $kflag = 1; }

# �ݒ�
our $not_repair_url_flag = 1;

# �R�����g�o�^�̍ő�/�ŏ�������
local $support_commment_max = 100;
local $support_commment_min = 3;

# �L�����Z���̐�������
local $cancel_maxsec = 30;

# CSS��`
our $css_text .= qq(
table,th,tr,td{border-style:none;}
td,th{padding:0.1em 0em 0.1em 0.5em;}
.td_count{text-align:right;padding-right:1em;}
input.comment{width:20em;}
div.alert{padding:1em;border:solid 1px #f00;margin:1em 0em;}
);

	# ���ʕ\���̏ꍇ�A���[�h���L���i���o�[���擾
	if($in{'no'} eq "" && $ENV{'REQUEST_METHOD'} eq "GET"){ $in{'no'} = $submode2; }

# �����`�F�b�N
$in{'no'} =~ s/\D//g;

# �Ǐ���
local($action);

# ���̋L�����J��
my($thread) = Mebius::BBS::thread_state($in{'no'},$realmoto);
local $sub = $thread->{'sub'};
local $key = $thread->{'key'};
local $sexvio = $thread->{'sexvio'};

	# ���L���̃L�[�ŃG���[����
	#if($key ne "1" && $key ne "2" && $key ne "3" && $key ne "5"){ &error("���̋L�������݂��Ȃ����A�폜�ς݁A�܂��̓��b�N���ł��B","","","Not-repair");}
	if($thread->{'keylevel'} < 0.5){ &error("���̋L�������݂��Ȃ����A�폜�ς݁A�܂��̓��b�N���ł��B","","","Not-repair");}

# �t�@�C����`
local $counter_file = "$main::bbs{'data_directory'}_crap_count_${moto}/$in{'no'}_cnt.cgi";

# �J�E���g�t�@�C�����J��
open(CNT_IN,"<",$counter_file);
my $support_top = <CNT_IN>; chomp $support_top;
my $support_top2 = <CNT_IN>; chomp $support_top2;
local ($count) = split (/<>/,$support_top);
close(CNT_IN);

	# �J�E���g�����Ȃ��ꍇ�A���l�[������
	if(!$count) { $count = "0"; }

# �w�b�_�����N�Ȃǂ̒�`
$sub_title = "�h$sub�h�ւ̂����ˁI";
$head_link3 = qq(&gt; <a href="$in{'no'}.html">$sub</a>);
$head_link4 = qq(&gt; �����ˁI);

	# ���e��̒�`
	if($alocal_mode) { $action = $script; } else { $action = "./"; }

	# ���[�h�U�蕪��
	if($in{'type'} eq "comment"){
			if($thread->{'keylevel'} < 1){ &error("�ߋ����O�ɂ̓R�����g�ł��܂���B");}
		&support_comment();
	}
	#elsif($in{'type'} eq "cancel"){ &support_cancel(); }
	elsif($mode eq "view" || $mode eq "kview" || $mode eq "support"){
			if($main::in{'thread_check'}){ &thread_check_do("",$main::realmoto,$main::in{'no'},$i_handle); }
			else{ &support_do("",$main::realmoto,$main::in{'no'},$i_handle); }
	}
	else{ &error("�y�[�W�����݂��܂���B( �T�|�[�g�P )"); }

exit;

}

use strict;

#-----------------------------------------------------------
# �L���̂����ˁI�����s
#-----------------------------------------------------------
sub support_do{

# �Ǐ���
my($type,$realmoto,$thread_number,$i_handle) = @_;
my($hitflag,@line,$count_handler,$topics_only_flag,$craped);
my($my_use_device) = Mebius::my_use_device();
my($my_connection) = Mebius::my_connection();
my($init_directory) = Mebius::BaseInitDirectory();
my $time = time;
our($concept,$enctrip);

	# �����`�F�b�N
	if($thread_number eq "" || $thread_number =~ /\D/){ main::error("�L���̎w�肪�ςł��B"); }
	if($realmoto eq "" || $realmoto =~ /\W/){ main::error("�f���̎w�肪�ςł��B"); }

	# �G���[
	if($my_use_device->{'bot_flag'}){ main::error("���̊�����͂����ˁI�ł��܂���B"); }

	# �u�ŋ߂̃��X�v�ւ̓o�^�����������Ȃ��ꍇ
	#if($main::in{'thread_check'}){ $topics_only_flag = 1; }

# ��d Cookie Set ���֎~
#$no_headerset = 1;

# ID�ƊǗ��ԍ����Z�b�g
our($encid) = &id();

# ���L�����Q�b�g
my($thread) = Mebius::BBS::thread({ ReturnRef => 1 },$realmoto,$thread_number);

	# �f�������e��~���[�h�̏ꍇ
	if(Mebius::Switch::stop_bbs()){ main::error("�f���S�̂ŁA�X�V���~���ł��B"); }

	# �����ˁI���֎~����Ă���f����
	if($concept =~ /NOT-SUPPORT/){ main::error("���̌f���ł͂����ˁI���o���܂���B","","","Not-repair"); }

# �A�N�Z�X����
main::axscheck("Post-only");

	# ���ɂ���Ă̓G���[
	if($my_use_device->{'level'} < 2){ &error("���̊�����͂����ˁI���o���܂���B","","","Not-repair"); }

	# �����ˁI�t�@�C���ŁA�A�������ˁI�𐧌�
	#if(!$topics_only_flag){
	#	($double_flag) = &support_check_double("deny");
	#}

	# �A�������ˁI�𐧌�
	#if($double_flag && !$alocal_mode){ &error("�����L���ɘA�����Ă����ˁI�͏o���܂���B","","","Not-repair"); }

# �J�E���g����
#$count += 1;

	# �����ˁI�t�@�C�����X�V
	if(!$topics_only_flag){

		my %select_renew;
		my $new_line = "<>$i_handle<>$encid<>$enctrip<><>$my_connection->{'account'}<>$my_connection->{'host'}<>$my_connection->{'cookie'}<>$my_connection->{'user_agent'}<>$time<><><><>$ENV{'REMOTE_ADDR'}<>\n";
		$select_renew{'+'}{'count'} = 1;
		($craped) = Mebius::BBS::crap_file({ NewCrap => 1 , Renew => 1 , select_renew => \%select_renew , new_line => $new_line },$realmoto,$thread_number);
			if($craped->{'done_flag'} && !Mebius::alocal_judge()){ main::error("���̋L���ɂ͂܂������ˁI�o���܂���B","","","Not-repair"); }

	}

	# �J�e�S�����̐V�������ˁI���X�V
	if(!$topics_only_flag){
		&category_newsupport("make");
	}

	# �����ˁI�����L���O�X�V
	if(!$topics_only_flag){
		&rank_support();
	}

	# ���e�����t�@�C�����X�V
	if(!$topics_only_flag){
		Mebius::HistoryAll("Renew My-file");
	}

# ���e�����ɋL�^������e
my $postdata_history = "$thread->{'subject'}<>$thread_number<><>$realmoto<>$main::head_title<>$main::server_domain<><><><><><><>";

# �����ˁI�������X�V
require "${init_directory}part_history.pl";
main::get_reshistory("ACCOUNT RENEW Crap-file New-crap My-file",undef,undef,$postdata_history);
main::get_reshistory("CNUMBER RENEW Crap-file New-crap My-file",undef,undef,$postdata_history);
#main::get_reshistory("KACCESS_ONE RENEW Crap-file New-crap My-file",undef,undef,$postdata_history);

# ���L�����X�V
my(%renew_thread);
$renew_thread{'s/g'}{'concept'} = $renew_thread{'.'}{'concept'} = qq( Crap-done);
#$renew_thread{'s/g'}{'concept'} = qq( Crap-not-done);
$renew_thread{'crap_count'} = $craped->{'count'};
Mebius::BBS::thread({ Renew => 1 , select_renew => \%renew_thread },$realmoto,$thread_number);

	# �������Ȃ��ꍇ�A���L���Ƀ��_�C���N�g���� ( Bot�̃N���[���΍�? )
	if($my_use_device->{'level'} < 2){
		Mebius::Redirect("","$thread->{'url'}","301");
	}

	# �R�����g�t�H�[����\������
	#elsif($in{'type'} eq "form"){
	#	&support_page("support",$craped->{'count'});
	#}

	# �������L���ɖ߂�
	else{

		if($my_use_device->{'type'} eq "Mobile"){
			require "${init_directory}k_view.pl";
			bbs_view_thread_mobile({ CrapDone => 1 });
		}
		else{
			require "${init_directory}part_view.pl";
			bbs_view_thread_desktop({ CrapDone => 1 });
		}
	}

exit;

}


#-----------------------------------------------------------
# �L���̃`�F�b�N�����s
#-----------------------------------------------------------
sub thread_check_do{

# �錾
my($type,$realmoto,$thread_number) = @_;
my(%type); foreach(split(/\s/,$type)){ $type{$_} = 1; } # �����^�C�v��W�J
my($my_use_device) = Mebius::my_use_device();
my($init_directory) = Mebius::BaseInitDirectory();
my $bbs_thread = new Mebius::BBS::Thread;

	# �����`�F�b�N
	if($thread_number eq "" || $thread_number =~ /\D/){ main::error("�L���̎w�肪�ςł��B"); }
	if($realmoto eq "" || $realmoto =~ /\W/){ main::error("�f���̎w�肪�ςł��B"); }

	# �G���[�`�F�b�N
	if(!$ENV{'HTTP_COOKIE'} || $my_use_device->{'bot_flag'}){ main::error("���̊��ł̓`�F�b�N�ł��܂���B"); }

# �A�N�Z�X����
&axscheck("Post-only");

# ���L�����Q�b�g
my($thread) = Mebius::BBS::thread({ ReturnRef => 1 },$realmoto,$thread_number);

# ���e�����ɋL�^������e
my $postdata_history = "$thread->{'subject'}<>$thread_number<><>$realmoto<>$main::head_title<>$main::server_domain<><><><><><><>";

# �����ˁI/�`�F�b�N�������X�V
require "${init_directory}part_history.pl";
main::get_reshistory("ACCOUNT RENEW Check-file New-check My-file",undef,undef,$postdata_history);
main::get_reshistory("CNUMBER RENEW Check-file New-check My-file",undef,undef,$postdata_history);
#main::get_reshistory("KACCESS_ONE RENEW Check-file New-check My-file",undef,undef,$postdata_history);

my $subject_utf8 = utf8_return($thread->{'subject'});
my %insert_for_history = ( bbs_kind => $realmoto , thread_number => $thread_number , subject => $subject_utf8 , last_response_num => $thread->{'res'} , last_response_target => $thread->{'res'} , create_content_time => $thread->{'posttime'} , last_modified => $thread->{'lastrestime'} );
#	if(Mebius::alocal_judge()){ Mebius::Debug::print_hash(\%insert_for_history); }

$bbs_thread->create_common_history(\%insert_for_history,{  },{ Check => 1 });

		if($main::kflag){
			require "${init_directory}k_view.pl";
			&bbs_view_thread_mobile("Thread-check-done");
		}
		else{
			require "${init_directory}part_view.pl";
			&bbs_view_thread_desktop({ ThreadCheckDone => 1 });
		}

exit;


}


#-----------------------------------------------------------
# �`�F�b�N�������b�Z�[�W
#-----------------------------------------------------------
sub thread_check_done_message{

# �錾
my($type) = @_;

# CSS��`
$main::css_text .= qq(
div.thread_checked{background:#cef;padding:0.3em 1.5em;margin:1em 0em 1em 0em;font-size:90%;color:#333;}
);

my $message = qq(<div class="thread_checked"><p>�L�����`�F�b�N���܂����I�@�X�V������Ɓu�ŋ߂̃��X�v�ɕ\\������܂��B<p> �폜����ꍇ��<a href="/_main/?mode=my">�}�C�y�[�W</a>�������p���������B</div>);

return($message);

}


#-----------------------------------------------------------
# �����ˁI������̃R�����g�t�H�[��
#-----------------------------------------------------------
sub thread_support_comment_form{

# �錾
my($type) = @_;
my($line,$form);
our($sikibetu,%in,$realmoto,$cnam,$kflag,$css_text,$body_javascript,$xclose,$kborder_bottom_in,$script);

# BODY Javascript ��`
$body_javascript = qq( onload="document.support.comment.focus()");

$css_text .= qq(
div.supported{background:#fee;padding:0.3em 1.5em;margin:1em 0em 1em 0em;font-size:90%;color:#333;}
);

$line .= qq(<form action="$script" method="post" name="support" style="$kborder_bottom_in"$sikibetu>);
$line .= qq(<div class="supported">);


	# �R�����g�𑗂����ꍇ
	if($in{'type'} eq "comment"){ 
		$line .= qq(�R�����g�𑗂�܂����I�@);
		$line .= qq(( <a href="./$in{'no'}_data.html">�L���f�[�^</a> �Ɍf�ڂ���܂��� )<br$main::xclose>);

		}

	# �����ˁI�������ꍇ
	else{
		$line .= qq(�����ˁI�𑗂�܂����B�@);
		#$line .= qq(��낵����Ή����R�����g���ǂ����B( <a href="./$in{'no'}_data.html" target="_blank" class="blank">�L���f�[�^</a> �̃y�[�W�Ō��J����܂� )<br$main::xclose>);
		#$line .= qq(<input type="hidden" name="mode" value="support"$xclose>);
		#$line .= qq(<input type="hidden" name="moto" value="$realmoto"$xclose>);
		#$line .= qq(<input type="hidden" name="no" value="$in{'no'}"$xclose>);
		#	if($kflag){ $line .= qq(<input type="hidden" name="k" value="1"$xclose>); }
		#$line .= qq(<input type="hidden" name="type" value="comment"$xclose>);
		#$line .= qq(�M���F <input type="text" name="name" value="$cnam" class="name"$xclose>);
		#	if($kflag){ $line .= qq(<br$main::xclose>); }
		#$line .= qq( �R�����g�F <input type="text" name="comment" value=""$xclose>);
		#$line .= qq(<input type="submit" value="���M"$xclose>);
	}

$line .= qq(</div>);

$line .= qq(</form>);

return($line);
}

no strict;

#-----------------------------------------------------------
# �R�����g���������s - no strict - 
#-----------------------------------------------------------
sub support_comment{

# �錾
my(@line,$myflag);
my($my_use_device) = Mebius::my_use_device();
my($init_directory) = Mebius::BaseInitDirectory();
my($basic_init) = Mebius::basic_init();
our($host,%in);

# �A���R�����g���֎~���鎞��
my $waithour = 24;

	# ���e�Ҕ���
	if($my_use_device->{'level'} < 2){ &error("���̊��ł̓R�����g�ł��܂���B","","","Not-repair"); }

# �A�������ˁI�R�����g�𐧌�
Mebius::Redun(undef,"Support-comment",60);

# �A�N�Z�X����
our($host) = main::axscheck("Postonly");

# ID��t�^
&id();

# �g���b�v��t�^
my($enctrip,$i_handle) = main::trip($in{'name'});

# �e��G���[
require "${init_directory}regist_allcheck.pl";
($i_handle) = shift_jis(Mebius::Regist::name_check($i_handle));
main::length_check($in{'comment'},"�R�����g",$support_commment_max,$support_commment_min);
my($comment) = &all_check(undef,$in{'comment'});
main::error_view();

# �t�`�̋L�^
my $put_age = $age;
	if(!$k_access){ $put_age = ""; }

	#my($crap) = Mebius::BBS::crap_file({ Flock2 => 1 }, $realmoto,$in{'no'});
	my($crap) = Mebius::BBS::crap_file($realmoto,$in{'no'});

# �o�^�҂��ǂ����𔻒�
my %select_renew;
$select_renew{'+'}{'res'} = 1;
my $new_resnum = $crap->{'res'} + 1;
my $new_line = "1<>$i_handle<>$encid<>$enctrip<>$comment<>$pmfile<>$host<>$cnumber<>$put_age<>$time<>$date<>$new_resnum<><>\n";
	my($craped) = Mebius::BBS::crap_file({ NewComment => 1 , Renew => 1 , new_line => $new_line , select_renew => \%select_renew },$realmoto,$in{'no'});
		if(!$craped->{'done_flag'}){ &error("�����ˁI������ł����R�����g�o�^�͏o���܂���B","","","Not-repair"); }
		if($craped->{'comment_done_flag'}){ &error("�A�����Ă����ˁI�R�����g�͑���܂���B"); }

	#($flag) = &support_check_double();
	#if(!$flag){ &error("�����ˁI������ł����R�����g�o�^�͏o���܂���B","","","Not-repair"); }

# ���b�N�J�n
#&lock("$in{'no'}");

# �J�E���g�t�@�C�����J��
#open(COUNT_IN,"<",$counter_file);
#flock(COUNT_IN,1);
#my $top1 = <COUNT_IN>; chomp $top1;
#my($count,$lasttime,$xips,$numbers,$res) = split(/<>/,$top1);
#$res++;

#my $top2 = <COUNT_IN>; chomp $top2;
#	while(<COUNT_IN>){
#		chomp;
#		my($key,$handle,$id,$trip,$comment,$account,$host2,$number,$age2,$lasttime,$date2,$res,$deleter) = split(/<>/);
#			if($lasttime + $waithour*60*60 > time){
#					if($account ne "" && $account eq $pmfile){ $myflag = 1; }
#					if($number ne "" && $number eq $cnumber){ $myflag = 1;}
#					if($k_access && $age2 && $age2 eq $age){ $myflag = 1; }
#					if(!$k_access && $host2 eq $host){ $myflag = 1; }
#			}
#		push(@line,"$key<>$handle<>$id<>$trip<>$comment<>$account<>$host2<>$number<>$age2<>$lasttime<>$date2<>$res<>$deleter<>\n");
#	}
#close(COUNT_IN);

# �����ˁI���玞�Ԃ��o�������Ă���ꍇ
#my($count,$lasttime) = split(/<>/,$top1);
#if(time >= $lasttime + 1*24*60*60){ &error("�O��̂����ˁI���玞�Ԃ��o�������Ă��܂��B","","","Not-repair"); }

# �d���o�^�̏ꍇ
#if($myflag && !$alocal_mode){ &error("�A���R�����g�͏o���܂���B","","","Not-repair"); }



# �ǉ�����s
#unshift(@line,"1<>$i_handle<>$encid<>$enctrip<>$comment<>$pmfile<>$host<>$cnumber<>$put_age<>$time<>$date<>$res<><>\n");

# �s�n�o�f�[�^��ǉ�
#unshift(@line,"$top2\n");
#unshift(@line,"$count<>$lasttime<>$xips<>$numbers<>$res<>\n");

# �J�E���g�t�@�C�����X�V
#Mebius::Fileout(undef,$counter_file,@line);

# ���b�N����
#&unlock("$in{'no'}");

# �T�C�g�S�̂̐V�������ˁI���X�V
&all_newsupport($i_handle,$comment);

# ���_�C���N�g
#Mebius::Redirect("","http://$server_domain/_$realmoto/$in{'no'}_data.html");
#Mebius::Redirect("","http://$server_domain/_$realmoto/$in{'no'}.html");

	# ���L����\��
	if($kflag){
			require "${init_directory}k_view.pl";
			&bbs_view_thread_mobile();
	}
	else{
			require "${init_directory}part_view.pl";
			&bbs_view_thread_desktop();
	}


# �W�����v��
$jump_url = "$in{'no'}_data.html";
$jump_sec = 0;


# HTML
my $print = qq(�R�����g���܂����B�i<a href="$jump_url">���߂�</a>�j);

Mebius::Template::gzip_and_print_all({},$print);

exit;

}



#-----------------------------------------------------------
# �T�C�g�S�̂̐V�������ˁI���X�V
#-----------------------------------------------------------
sub all_newsupport{

# �Ǐ���
my($line,$i,$key);
my($handle,$comment) = @_;
my($init_directory) = Mebius::BaseInitDirectory();
our($concept);

	# ���^�[��
	if($secret_mode){ return; }

# �����L�[
$key = 1;

	# ��\���ɂ���ꍇ
	if($sexvio){ $key = 2; }
	if($sub =~ /(��|�\\|�O��|BL|GL|�a�k|�f�k)/){ $key = 2; }
	if($main::bbs{'concept'} =~ /Sousaku-mode/ && $sub =~ /(�C�W��|������|�s��|�Ղ�|�c��)/){ $key = 2; }

# �ǉ�����s
$line .= qq($key<>$moto<>$title<>$in{'no'}<>$sub<>$handle<>$comment<><>$time<>$date<>\n);

# �t�@�C���ǂݍ���
open(IN,"<","${init_directory}_sinnchaku/all_newsupport.cgi");
flock(IN,1);
	while(<IN>){
		$i++;
			if($i <= 500){ $line .= $_; }
	}
close(IN);

# �t�@�C���X�V
Mebius::Fileout(undef,"${init_directory}_sinnchaku/all_newsupport.cgi",$line);

}



#-----------------------------------------------------------
# �J�e�S�����̐V�������ˁI���X�V
#-----------------------------------------------------------

sub category_newsupport{

# �Ǐ���
my($line,$i,$key,$flag);
my($type,$select_time) = @_;
my($init_directory) = Mebius::BaseInitDirectory();

	# ���^�[��
	if($secret_mode){ return; }

# �����L�[
$key = 1;

	# ��\���ɂ���ꍇ
	if($sexvio){ $key = 2; }
	if($sub =~ /(��|�\\|�O��|BL|GL|�a�k|�f�k)/){ $key = 2; }
	if($main::bbs{'concept'} =~ /Sousaku-mode/ && $sub =~ /(�C�W��|������|�s��|�Ղ�|�c��)/){ $key = 2; }

	# �ǉ�����s
	if($type eq "make"){
		$line .= qq($key<>$moto<>$title<>$in{'no'}<>$sub<>$handle<>$comment<><>$time<>$date<>\n);
	}

# �t�@�C���ǂݍ���
open(IN,"<","${init_directory}_sinnchaku/_category/${category}_newsupport.cgi");
flock(IN,1);

	while(<IN>){
		chomp;
		my($key,$moto2,$title2,$no2,$sub,$handle,$comment,$res,$lasttime,$date2) = split(/<>/);
		$i++;
			if($type eq "make" && ($no2 eq $in{'no'} && $moto2 eq $moto) ){ next; }
			if($type eq "cancel" && $select_time eq $lasttime){ $flag = 1; next; }
			if($i <= 10){ $line .= qq($key<>$moto2<>$title2<>$no2<>$sub<>$handle<>$comment<>$res<>$lasttime<>$date2<>\n); }
	}
close(IN);

# ���^�[��
if($type eq "cancel" && !$flag){ return; }

# �t�@�C���X�V
Mebius::Fileout(undef,"${init_directory}_sinnchaku/_category/${category}_newsupport.cgi",$line);

}


#-----------------------------------------------------------
# �����ˁI�������L���O���X�V
#-----------------------------------------------------------
sub rank_support{

my($init_directory) = Mebius::BaseInitDirectory();

	# ���^�[��
	if($secret_mode){ return; }
	if($count < 25){ return; }

# �Ǐ���
my($line,$i);
my($init_bbs) = Mebius::BBS::init_bbs_parmanent_auto();

	# ��\���ɂ���ꍇ
	if($sexvio){ $key = 2; }
	if($sub =~ /(��|�\\|�O��|BL|GL|�a�k|�f�k)/){ $key = 2; }
	if($init_bbs->{'concept'} =~ /Sousaku-mode/ && $sub =~ /(�C�W��|������|�s��|�Ղ�|�c��)/){ $key = 2; }

# �ǉ�����s
$line .= qq(1<>$count<>$moto<>$title<>$in{'no'}<>$sub<>\n);

# ���b�N�J�n
&lock("supportranking");

# �t�@�C���ǂݍ���
open(IN,"<","${init_directory}_sinnchaku/rank_support.cgi");
	while(<IN>){
	$i++;
	my($key2,$count2,$moto2,$title2,$no2,$sub2) = split(/<>/,$_);
		if($moto2 eq $moto && $no2 eq $in{'no'}){ next; }
		if($i <= 500){ $line .= $_; }
	}
close(IN);

# �t�@�C���X�V
Mebius::Fileout(undef,"${init_directory}_sinnchaku/rank_support.cgi",$line);

# ���b�N����
&unlock("supportranking");

}




1;
