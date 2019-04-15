
use Mebius::Auth;
use Mebius::SNS::Friend;
use Mebius::Newlist;
use Mebius::SNS::Feed;
package main;
use Mebius::Export;
use strict;

#-----------------------------------------------------------
# SNS ���L�̐V�K���e
#-----------------------------------------------------------
sub auth_fdiary{

# �錾
my($maxmsg,$minmsg) = (3000,20);
my($my_account) = Mebius::my_account();
my($param) = Mebius::query_single_param();
our($auth_url,$pmname,$birdflag,$title,$css_text);

# �^�C�g����`
our $sub_title = qq(�V�������L | $title);
our $head_link3 = qq(&gt; <a href="$auth_url$my_account->{'id'}/">$my_account->{'name'}</a>);
our $head_link4 = qq(&gt; �V�������L);

# CSS��`
$css_text .= qq(
div.error{line-height:1.6em;background:#fee;padding:1em;color:#f00;}
textarea{width:95%;height:300px;}
.edit{margin-top:1em;background-color:#cdf;padding:0em 1em 1em 1em;border:solid 1px #99f;}
.pinput{width:95%;}
.maxmsg{color:#080;font-size:90%;}
h1{color:#080;}
h2{margin:0em;}
.alert{color:#f00;}
ul.alert_area{padding:1em 2.0em 1em 2.5em;font-size:90%;border:solid 1px #f00;}
li{line-height:2.0em;}
.nomargin{margin:0em;}
input.sub{width:50%;}
.big{font-size:150%;}
);

	if($ENV{'HTTP_USER_AGENT'} =~ /MSIE 8.0/){ $css_text .= qq(textarea{width:700px;}); }

	# ���O�C�����Ă��Ȃ��ꍇ
	if(!$my_account->{'login_flag'}){ &auth_fdiary_preview("���̃y�[�W�𗘗p����ɂ́A���O�C�����Ă��������B"); }

	# �A�N�Z�X����
	if($ENV{'REQUEST_METHOD'} eq "POST"){ 
		main::axscheck("ACCOUNT");
	}

	# ���e����
	if(time < $my_account->{'next_diary_post_time'} && !$main::myadmin_flag && !Mebius::alocal_judge()){
		my($left_date) = Mebius::SplitTime("Get-top-unit",$main::myaccount{'next_diary_post_time'} - time);
		&auth_fdiary_preview("�V�K���e�͂���$left_date�҂��Ă��������B");
	}

	# �M�����Ȃ��ꍇ
	if($birdflag){ &auth_fdiary_preview("���L�������ɂ́A���Ȃ��̕M����ݒ肵�Ă��������B"); }

	# ���[�h�U�蕪��
	if($param->{'action'} eq "new"){ &auth_fdiary_post("",$maxmsg,$minmsg); } else { &auth_fdiary_form("",$maxmsg,$minmsg); }

}


#-----------------------------------------------------------
# ���L�̐V�K���e����
#-----------------------------------------------------------

sub auth_fdiary_post{

# �Ǐ���
my($type,$maxmsg,$minmsg) = @_;
my($line,$indexline,$pastline,$waitline,$lastman,$i1,$allline,$lastpost,$waitline,$month_index_handler,$diary_index_handler);
my($newkey_newsdiary,%renew_myaccount,$redun_subject_flag,$new_concept,$pastline2,$diary_thread_file,$index_ok_flag);
my $sns_diary = new Mebius::SNS::Diary;
my($my_account) = Mebius::my_account();
my($now_date) = Mebius::now_date_multi();
my($basic_init) = Mebius::basic_init();
my($param) = Mebius::query_single_param();
my $time = time;
our(%in,$e_com,$smlength,$bglength,$xip,$fook_error);


# �f�B���N�g����`
my($account_directory) = Mebius::Auth::account_directory($my_account->{'id'});
	if(!$account_directory){ die("Perl Die! Account directory setting is empty."); }

# �V���ꗗ�̍ő�s��
my $max_newdiary = 2000;

# �t�H�[���擾
my($form) = auth_fdiary_getform();

# �G���[���̃t�b�N���e
$fook_error = qq(<h1>���L�̏C��</h1>$form);

	# �f�d�s���M���֎~
	if($ENV{'REQUEST_METHOD'} ne "POST"){ &auth_fdiary_preview("�f�d�s���M�͏o���܂���B"); }

	# �e��G���[
	if($in{'sub'} eq "" || $in{'sub'} =~ /^(\x81\x40|\s|<br>)+$/){ $in{'sub'} = "���� ($now_date->{'year'}�N$now_date->{'month'}��$now_date->{'day'}�� $now_date->{'hour'}��$now_date->{'minute'}��)"; }
	if($in{'comment'} eq "" || $in{'comment'} =~ /^(\x81\x40|\s|<br>)+$/){ $e_com .= qq(���{��������܂���B<br>); }

# �e��`�F�b�N
my($init_directory) = Mebius::BaseInitDirectory();
require "${init_directory}regist_allcheck.pl";
Mebius::Regist::name_check($my_account->{'name'});
my($new_comment) = &all_check(undef,$in{'comment'});
my($new_subject) = &subject_check("",$in{'sub'});

	if(!Mebius::alocal_judge()){
			if($bglength > $maxmsg){ $e_com .= qq(���{���͑S�p$maxmsg�����ȓ��ɗ}���Ă��������B�i���� $bglength �����j<br>); }
			if($smlength < $minmsg){ $e_com .= qq(���{���͑S�p$minmsg�����ȏ�������Ă��������B�i���� $smlength �����j<br>); }
	}

&error_view("AERROR Target","auth_fdiary_preview");

# �v���r���[
if($in{'preview'}){ &auth_fdiary_preview(); }

# ���b�N�J�n
&lock("auth$my_account->{'id'}");

# ���L���s�C���f�b�N�X�̍ő�s
my $max_nowindex = 1000;

# ���ʂ̎����t�H�[�}�b�g���`
my $time_data_line = "$now_date->{'year'},$now_date->{'month'},$now_date->{'day'},$now_date->{'hour'},$now_date->{'minute'},$now_date->{'second'}";

# ���s�C���f�b�N�X��ǂݍ���
my($now_index) = Mebius::SNS::Diary::index_file_per_account({ file_type => "now" },$my_account->{'id'});
my $newnum = $now_index->{'newest_diary_number'};

	# �^�C�g���̏d���`�F�b�N
	foreach my $data (@{$now_index->{'data_line'}}){
			if($data->{'subject'} eq $new_subject && $new_subject ne ""){
				auth_fdiary_preview("�u$new_subject�v�Ƃ����薼�́A�ߋ��̓��L�Əd�����Ă��܂��B");
			}
	}

	# ���L�t�@�C�����`
	for(1..100){ # �t�@�C�����P���J���̂ł͂Ȃ��A�f�B���N�g���̈ꗗ����擾����悤�ɂ�����
		$newnum++;
		$diary_thread_file = "${account_directory}diary/$my_account->{'id'}_diary_${newnum}.cgi";
			if(!-f $diary_thread_file){
				$index_ok_flag = 1;
				last;
			}
	}

	if(!$index_ok_flag){
		auth_fdiary_preview("�f�[�^�����Ă��邽�߁A�������߂܂���B�i�d���������݁j$newnum");
	}

	# �����s�C���f�b�N�X���X�V
	{
		my %renew_top_data;
		$renew_top_data{'newest_diary_number'} = $newnum;
		my $new_line_diary_index = qq(1<>$newnum<>$new_subject<>0<>$time_data_line<>$time<>\n);

		Mebius::SNS::Diary::index_file_per_account({ Renew => 1 , file_type => "now" , new_line => $new_line_diary_index , renew_top_data => \%renew_top_data },$my_account->{'id'});
	}


	# �V�����R���Z�v�g��ݒ�
	if(!$in{'newlist'}){ $new_concept .= qq( Not-ranking-crap); }

# �ǉ�����s�i���L�P�̃t�@�C���j

	# ���L�P�̃t�@�C������
	#if(Mebius::alocal_judge()){
	#	$line .= qq(1<>$newnum<>$new_subject<>0<>$time_data_line<>$time<><><><><><><>$new_concept<>\n);
	#	$line .= qq(1<>0<>$my_account->{'id'}<>$my_account->{'name'}<>$my_account->{'enctrip'}<>$my_account->{'encid'}<>$new_comment<>$time_data_line<>$my_account->{'color2'}<>$xip<>\n);
	#	Mebius::Fileout("","$diary_thread_file.bk",$line);
	#}

	# �����L�{�̃t�@�C����V�K�쐬
	{
		my %post;
		$post{'key'} = 1;
		$post{'number'} = $newnum;
		$post{'subject'} = $new_subject;
		$post{'res'} = 0;
		$post{'concept'} = $new_concept;
		$post{'postdates'} = $time_data_line;
		$post{'posttime'} = time;
		$post{'hidden_from_list'} = 1 if(!$param->{'newlist'});

		$post{'owner_handle'} = $my_account->{'name'};
		my $push_line .= qq(1<>0<>$my_account->{'id'}<>$my_account->{'name'}<>$my_account->{'enctrip'}<>$my_account->{'encid'}<>$new_comment<>$time_data_line<>$my_account->{'color2'}<>$xip<>\n);

		Mebius::Fileout("Allow-empty",$diary_thread_file); # �t�@�C�����̂�V�K�쐬
		Mebius::Auth::diary({ Renew => 1 , Post => 1 , push_line => $push_line },$my_account->{'id'},$newnum,undef,\%post);
	}

# �ߋ��i���ʁj�C���f�b�N�X�ǂݍ���
open($month_index_handler,"<","${account_directory}diary/$my_account->{'id'}_diary_$now_date->{'year'}_$now_date->{'month'}.cgi");
	while(<$month_index_handler>){ $pastline2 .= $_; }
close($month_index_handler);

	# �����̉ߋ��C���f�b�N�X���Ȃ��ꍇ�A�S�C���f�b�N�X�ɒǉ�����
	if($pastline2 eq ""){

		# �S�C���f�b�N�X��ǂݍ���
		$allline = qq(1<>$now_date->{'year'}<>$now_date->{'month'}<>\n);
		open(ALL_INDEX_IN,"<","${account_directory}diary/$my_account->{'id'}_diary_allindex.cgi");
			while(<ALL_INDEX_IN>){
				my($key,$year,$month) = split(/<>/,$_);
				unless($year eq $now_date->{'year'} && $month eq $now_date->{'month'}){ $allline .= $_; }
			}
		close(ALL_INDEX_IN);

		# �S���Ԃ̓��L�C���f�b�N�X���X�V
		Mebius::Fileout("","${account_directory}diary/$my_account->{'id'}_diary_allindex.cgi",$allline);

	}

		# �ߋ��i���ʁj�C���f�b�N�X�X�V
		$pastline = qq(1<>$newnum<>$new_subject<>0<>$time_data_line<>$time<><><>\n);
		$pastline .= $pastline2;
		Mebius::Fileout("","${account_directory}diary/$my_account->{'id'}_diary_$now_date->{'year'}_$now_date->{'month'}.cgi",$pastline);


	# ���V���C���f�b�N�X�̐����i�S�����o�[���j
	if($my_account->{'osdiary'} ne "0" && $my_account->{'osdiary'} ne "2"){

		# ����
		my($plustype_alldiary);
				if(!$main::in{'newlist'}){ $plustype_alldiary .= qq( Hidden-diary); }

			# �V�����X�g�ɍڂ��邩�ۂ�
			foreach(split/<br>/,$new_comment){
					#if($_ =~ /(��|��)��ꂽ�l)/){ $plustype_alldiary .= qq( Hidden-diary); }
					if($_ =~ /�n��/ && $_ =~ /(�o�g��|�ł�)/){ $plustype_alldiary .= qq( Hidden-diary); }
			}

			# �薼�`�F�b�N
			if($new_subject =~ /(����|�L|�����ˁI)(.{0,30})(�~����|�ق���|�䂸����|������|�b���|(����|�N�_|��)(����|�T�C)|���傤����|����|\Q����[����\E)/){ $plustype_alldiary .= qq( Hidden-diary); }

				# ���ӓ��e�t�@�C�����X�V
				#Mebius::Auth::all_members_diary("New-file New-line Renew $plustype_alldiary",$my_account->{'id'},$newnum,$new_subject,$new_comment,$my_account->{'name'});

					# ���ӓ��e�t�@�C�����X�V
					#if($main::a_com){
						#Mebius::Auth::all_members_diary("Alert-file New-line Renew $plustype_alldiary",$my_account->{'id'},$newnum,$new_subject,$new_comment,$my_account->{'name'});
					#}
			}

# ���b�N����
&unlock("auth$my_account->{'id'}");

# �l�����~�}�C���r�X�V�̃C���f�b�N�X�̍쐬
Mebius::Auth::FriendIndex("New-diary",$my_account->{'file'},$newnum,$new_subject,$my_account->{'name'});

# �����X�����X�V
Mebius::Newlist::Daily("Renew Postdiary-auth");

	# ���t�@�C���́y�V�K���e�҂����ԁz���X�V
	if($my_account->{'level2'} >= 1){
		$renew_myaccount{'next_diary_post_time'} = time + 6*60;
	}
	else{
		$renew_myaccount{'next_diary_post_time'} = time + 10*60;
	}


# �����̃I�v�V�����t�@�C�����X�V
#Mebius::Auth::Optionfile("Renew",$my_account->{'file'},%renew_myaccount);

# ���t�@�C�����X�V
Mebius::Auth::File("Renew Option",$my_account->{'file'},\%renew_myaccount);

# �����̊�{���e�����t�@�C�����X�V
Mebius::HistoryAll("Renew My-file");

# �t�B�[�h�p�̃������e�[�u�����X�V
my $feed = new Mebius::SNS::Feed;
#my $sns_url = new Mebius::SNS::URL;
#my $diary_url = $sns_url->diary_url($my_account->{'id'},$newnum);
my $hidden_flag = 1 if(!$param->{'newlist'});
my $update_all_members_news = hash_to_utf8({ content_type => "sns_diary" , data1 => $newnum , post_time => time , subject => $new_subject , account => $my_account->{'id'} , handle => $my_account->{'handle'} , hidden_flag => $hidden_flag });
$feed->insert_main_table($update_all_members_news);

my $subject_utf8 = utf8_return($new_subject);
my $handle_utf8 = utf8_return($my_account->{'name'});
$sns_diary->create_common_history_on_post({ content_targetA => $my_account->{'id'} , content_targetB => $newnum , subject => $subject_utf8 , handle => $handle_utf8 , content_create_time => time  });

#Mebius::Redirect("","$basic_init->{'auth_url'}$my_account->{'id'}/#DIARY");
Mebius::redirect("$my_account->{'profile_url'}d-$newnum");

# �����I��
exit;

}


#-----------------------------------------------------------
# �v���r���[
#-----------------------------------------------------------
sub auth_fdiary_preview{

# �錾
my($msg) = @_;
my($submit,$com_value,$newlist_checked);
our(%in,$lockflag,$footer_link,$footer_link2,$sikibetu,$action);

	# �G���[���A�����b�N
	if ($lockflag) { &unlock($lockflag); }

	# �`�F�b�N
	if($in{'newlist'}){ $newlist_checked = " checked"; }

$com_value = qq(\n$in{'comment'});
$com_value =~ s/<br>/\n/g;

if($msg){
$msg = qq(<div class="error">�G���[�F<br$main::xclose> $msg</div><br><br>);
}
else{ $msg = qq(<span class="blue">���v���r���[���ł��B�܂��������܂�Ă��܂���B</span><br><br>); }

my $print = qq(
$footer_link
<form action="$action" method="post"$sikibetu>
<div>
$msg
<h1>$in{'sub'}</h1>

<span style="color:#$main::myaccount{'color2'};">$in{'comment'}</span><br><br>

);

#<h2>�C���t�H�[��</h2><br>

$print .= sns_diary_new_form_core($in{'sub'},$com_value);


$print .= $footer_link2;


Mebius::Template::gzip_and_print_all({},$print);

exit;

}



#-----------------------------------------------------------
# ���L���e�t�H�[���̕\��
#-----------------------------------------------------------

sub auth_fdiary_form{

my($type,$maxmsg,$minmsg) = @_;
our($sns_rule,$title,$guide_url,$footer_link,$footer_link2);

# �t�H�[���擾
my($form) = auth_fdiary_getform();

my $text2 = qq(
<ul class="alert_area">
<li>�u���L�{�́v��u���L�ւ̃R�����g�v�́A���Ȃ����Ǘ�����K�v������܂��B<strong class="red">�l���A�}�i�[�ᔽ�A���ӂ̂��铊�e�A�r�炵�A���f���e�Ȃǂ͕K���폜���Ă��������B</strong>�Ǘ�����Ă��Ȃ��A�J�E���g��\�\\��\�Ȃ��Ƀ��b�N�i�폜�j�����Ă��������ꍇ������܂��B
<li><a href="$sns_rule">$title�̃��[��</a>������ď�������ł��������B�u���I�ȓ��e���܂܂����́v�͈ꊇ�֎~�ł��B�i�薼�Ő��I�Ȃ��̂�A�z��������̂�A�l�^�E�W���[�N���폜�ƂȂ�ꍇ������܂��j
<li><a href="${guide_url}%A5%EB%A1%BC%A5%EB%A3%D1%A1%F5%A3%C1">�܂������������́i�܂��́A�قƂ�Ǔ������́j�𖳌��ɑ��₵�Ă䂭�u�`�F�[�����e�E�R�s�y���e�v�͋֎~�ł��B</a>
<li>����<strong class="red">�u�}�i�[���������O�`�v��u�o�b�V���O�ړI�̓��L�v�u�\\�����L�E�\\���o�g���v�u�i�`���b�g���Ƃ��Ắj�����񍐂̓��L�v�u�Z����`���L�v</strong>�ȂǍ��Ȃ��悤�A���ӂ����肢���܂��B 
<li>�l�i���̃��[�U�[�l�Ȃǁj�ɑ΂��Ă̔ᔻ��ӌ���W�͂��������������B�ӌ�������ꍇ�́A���J�ɂ��̕����g�Ƙb�������Ă��������B
<li><strong class="red">�u�d�b�ԍ������v�u���[���A�h���X�����v�u�Z���f�ځv�Ȃǂ̌l���f�ڂ́A��΂ɂ�߂Ă��������i���ځA�Ԑڂ��킸�j</strong>�B�����A�J�E���g���b�N�A���e���������Ă���������\�\\��������܂��B
<li>�r�m�r�ɂ��Ă̂���āA���v�]��<a href="http://aurasoul.mb2.jp/_qst/2245.html">����^�c��</a>�܂ł��肢���܂��B
<li>�u�\\���v�u�������O�`�v�Ȃǂłǂ����Ă��䖝�ł��Ȃ��ꍇ�� �y <a href="http://mb2.jp/_main/hole.html" target="_blank" class="blank big">���l�̌�</a> �z�������p���������B</li>
</ul>
<br>
);

my $print = <<"EOM";
$footer_link
<h1>�V�������L�̓��e</h1>
$text2
$form
EOM

Mebius::Template::gzip_and_print_all({ NotMebiusDiaryButton => 1 },$print);

exit;

}

#-----------------------------------------------------------
# ���L���e�t�H�[���̕\��
#-----------------------------------------------------------
sub auth_fdiary_getform{

my($sub,$comment,$form);
my($type,$maxmsg,$minmsg,$text2) = @_;
my($q) = Mebius::query_state();
my($my_account) = Mebius::my_account();
my($form);
our(%in,$sikibetu,$ipalert,$action,$footer_link,$footer_link2);

	# �X�g�b�v���[�h
	if($main::stop_mode =~ /SNS/){ return("���݁ASNS�S�̂œ��e��~���ł��B"); }

	# �������͓��e���`
	if($ENV{'REQUEST_METHOD'} eq "POST"	|| ($q->param('account') eq $my_account->{'id'} && $my_account->{'login_flag'})){
		$sub = $in{'sub'} if($q->param('sub'));
		$sub = $in{'subject'} if($q->param('subject'));
		$sub =~ s/<br>//g;
		$comment = $in{'comment'};
		$comment =~ s/<br>/\n/g;
	}


$form .= $text2;
$form .= sns_diary_new_form_core($sub,$comment);

return($form);

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub sns_diary_new_form_core{

my $use = shift if(ref $_[0] eq "HASH");
my $sub = shift;
my $comment = shift;
my $html = new Mebius::HTML;
my($form);
my($param) = Mebius::query_single_param();
our($sikibetu,$action);


#��F <input type="text" name="sub" value="$in{'sub'}" class="sub"><br><br>
#<textarea name="comment" class="textarea" cols="25" rows="5">$com_value</textarea>
#<br><br><input type="submit" name="preview" value="���̓��e�Ńv���r���[����" class="ipreview">
#<input type="submit" value="���̓��e�ő��M����" class="isubmit">
#<input type="checkbox" name="newlist" value="1" id="check_newlist"$newlist_checked> <label for="check_newlist">�S�����o�[�̐V���ꗗ�ɍڂ���</label>
#<input type="hidden" name="mode" value="fdiary">
#<input type="hidden" name="action" value="new">
#</div>
#</form>



$form .= qq(
<form action="$action" method="post"$sikibetu>
<div>
<h2>�薼</h2>
<input type="text" name="sub" value=").e($sub).qq(" class="pinput"><br>
<h2>�{��</h2>
<textarea name="comment" class="textarea" cols="25" rows="5">).e($comment).qq(</textarea>

<br><input type="submit" name="preview" value="�v���r���[" class="ipreview">
<input type="submit" value="���M����" class="isubmit">);

$form .= $html->input("radio","on_feed","1",{ text => "�V���ɍڂ���" , default_checked => 1  });
$form .= $html->input("radio","on_feed","0",{ text => "�V���ɍڂ��Ȃ�" });

$form .= qq(
<input type="hidden" name="mode" value="fdiary">
<input type="hidden" name="action" value="new">
</div>
</form>
);

$form;

}


1;
