
use strict;
use Mebius::SNS::Friend;
use Mebius::SNS::Message;
use Mebius::SNS::Diary;
package main;
use Mebius::Export;

#-------------------------------------------------
# �v���t�B�[���\��
#-------------------------------------------------
sub auth_prof{

# �Ǐ���
my($file,$ads1,$star,$member_mark,$print);
my($init_directory) = Mebius::BaseInitDirectory();
my($basic_init) = Mebius::basic_init();
my($my_account) = Mebius::my_account();
my(%account,$profile_line,$myform,$newcomment,$newdiary_index,$message_news,$friend_diary,$addata,$error_text,%res_news,$news_link,$friendlink,$pri_ppencid,$pri_ppenctrip,$question_history);
our($css_text,$kflag,$kfontsize_h2,$hername,%box,%in,$adir,$xclose,$friend_tag,$script,$kfontsize_h1,$title);


	# �A�N�Z�X�U�蕪�� ( �f�X�N�g�b�v�Ł����o�C���� )
	if(our $submode1 eq ""){
		our $divide_url = "$basic_init->{'auth_url'}$in{'account'}/iview";
	}

	# �A�N�Z�X�U�蕪�� ( ���o�C���Ł��f�X�N�g�b�v�� )
	if(our $submode1 eq "iview"){
		our $divide_url = "$basic_init->{'auth_url'}$in{'account'}/";
		#if($device_type eq "desktop"){ &divide($divide_url,"desktop"); }

		# �g�єł�URL���܂Ƃ߂�
		Mebius::Redirect(undef,"$basic_init->{'auth_url'}$in{'account'}/",301);

	}

# �g�єŃ}�C�y�[�W�̖߂��
our $mybackurl = "$basic_init->{'auth_url'}$in{'account'}/";

	# �L���̒�`
#	if(!Mebius::alocal_judge()){
#$ads1 = '
#<hr>
#<script type="text/javascript"><!--
#google_ad_client = "pub-7808967024392082";
#/* �r�m�r */
#google_ad_slot = "2938623053";
#google_ad_width = 300;
#google_ad_height = 250;
#//-->
#</script>
#<script type="text/javascript"
#src="http://pagead2.googlesyndication.com/pagead/show_ads.js">
#</script>';
#	}

#�����`�F�b�N
my $account = $file = $in{'account'};

	# �A�J�E���g������
	if(Mebius::Auth::AccountName(undef,$in{'account'})){ main::error("�A�J�E���g���̎w�肪�ςł��B"); }
	if($file eq ""){ main::error("�A�J�E���g���w�肵�Ă��������B"); }

# CSS��`
$css_text .= qq(
h1{display:inline;}
.ptextarea{width:95%;height:300px;}
.max_msg{color:#f00;font-size:90%;}
.date{text-align:right;}
.lock{color:#080;}
.emergency{color:#f00;font-size:90%;font-weight:normal;}
.lim{margin-bottom:0.3em;line-height:1.25;}
.deleted{font-size:90%;color:#f00;}
.cbottun{margin-top:0.5em;}
.clog{font-size:90%;}
a.me:link{color:#f00;}
a.me:visited{color:#f40;}
.tag{margin-top:0.6em;word-spacing:0.3em;font-size:90%;line-height:2.0;}
.myfriend{font-size:90%;margin-top:0.6em;word-spacing:0.3em;}
.navilink{margin-top:0.6em;word-spacing:0.3em;}
.vrireki{word-spacing:0.2em;line-height:1.5;margin:0em;}
.sml{font-size:80%;color:#080;}
.andmore{color:#080;font-style:ltalic;}
.news{font-size:90%;}
.prof_next{font-size:140%;}
.cut_prof1{font-size:90%;line-height:1.4;}
.cut_prof2{font-size:80%;line-height:1.4;}
div.prof{line-height:1.4;}
.news_link{font-size:90%;}
);

# �t�@�C���I�[�v��
(%account) = Mebius::Auth::File("Option Kr-submit Kr-oneline Get-friend-status",$file,%$my_account);

	# ���[�U�[�F�w��
	if($account{'color1'}){ $css_text .= qq(h2{background-color:#$account{'color1'};border-color:#$account{'color1'};}); }

	# �����̃v���t�B�[���y�[�W�̏ꍇ�A�ҏW�t�H�[�����o��
	if($my_account->{'admin_flag'}){
			require "${init_directory}auth_myform.pl";
				if(our $submode1 eq "edit" && our $submode2 eq "detail"){ ($myform) = &auth_myform("Detail",$file); }
				else{ ($myform) = &auth_myform("",$file); }
	}
	elsif($account{'myprof_flag'}){ $myform = qq(<h2$kfontsize_h2>�ݒ�ύX</h2><a href="./edit#EDIT">���ݒ�ύX�t�H�[����</a>); }

	# �g���b�v
	if($account{'enctrip'}){ $pri_ppenctrip = "��$account{'enctrip'}"; }

	# �v���t�\�����̒���
my $viewaccount = $account{'file'};
	if($account{'name'} eq "none"){ $viewaccount = "****"; }
	if($account{'name'} eq ""){ $hername = qq($viewaccount); }
	else{
		my($account);
		$account = $viewaccount;
		$hername = qq($account{'name'}$pri_ppenctrip <span class="green">).e("\@$file").qq(</span>);
	}

# �^�C�g������
our $sub_title = "$account{'name'} \@$file | ���r�����r�m�r";
#if($account{'myprof_flag'}){ our $head_link2 = qq(&gt; $title); }
our $head_link3 = qq(&gt; $account{'name'});

	# �}�C���r�\�������N
	if($my_account->{'file'}){
			if($account{'friend_status_to'} eq "me"){ $friendlink = qq(<span style="color:#080;">����</span>); }
			elsif($account{'friend_status_from'} eq "deny"){ $friendlink = qq(<span style="color:#f00;">���Ȃ����֎~�ݒ蒆</span>); }
			elsif($account{'friend_status_to'} eq "deny"){ $friendlink = qq(); }
			#elsif($account{'friend_status_to'} eq "apply"){ $friendlink = qq(<span style="color:#080;">���Ȃ���$main::friend_tag�\\�����Ă��܂�</span>); }
			elsif($account{'friend_status_from'} eq "apply"){ $friendlink = qq(<span style="color:#080;">$main::friend_tag�\\����</span>); }
			elsif($account{'friend_status_to'} eq "friend"){ $friendlink = qq( <span style="color:#080;">�}�C���r</span> ); }
			elsif($account{'herbirdflag'}){ $friendlink = qq( �M�����ݒ� ); }
			elsif(our $birdflag){ $friendlink = qq( $friend_tag�\\������ɂ�<a href="$basic_init->{'auth_url'}#EDIT">���Ȃ��̕M�����쐬</a>���Ă��������B ); }
			else{ $friendlink = qq( <a href="$script?mode=befriend&amp;account=$file">�}�C���r�\\��</a> ); } 
	}
	else{
		my($request_url_encoded) = Mebius::request_url_encoded();
		$friendlink = qq(�}�C���r�\\������ɂ�<a href="$basic_init->{'auth_url'}?backurl=$request_url_encoded">���O�C���i�܂��͐V�K�o�^�j</a>���Ă��������B );
	}


	# �֎~�ݒ胊���N
	if($my_account->{'file'} && !$account{'myprof_flag'}){
		$friendlink .= qq( <a href="./?mode=befriend&amp;decide=deny">�֎~�ݒ�</a> );
	}

	# ���b�Z�[�W�t�H�[���ւ̃����N
	if($account{'editor_flag'}){
		#(%box) = Mebius::Auth::MessageBox("Get-new-status",$account{'file'},"catch");
	}
	if($account{'myprof_flag'} && $account{'allow_message_flag'}){
		$friendlink .= qq( <a href="./?mode=message">���b�Z�[�W</a>\n);
	}
	elsif($account{'allow_message_flag'} && $my_account->{'allow_message_flag'}){
		$friendlink .= qq(<a href="${main::adir}$my_account->{'file'}/?mode=message&amp;to=$file">���b�Z�[�W</a>\n);
	}


	# �L
	if(!$my_account->{'login_flag'} && !$account{'votepoint'}){ }
	elsif($my_account->{'allow_vote'} eq "not-use"){ }
	else{
		my $cat = $account{'votepoint'} || 0;
		$friendlink .= qq( <a href="./vote">�L\($cat\)</a> );
	}


# �v���t�B�[�����擾
($profile_line) = &auth_viewprof("",$file,%account);

	# �h�c�A�g���b�v�̐��`
	if($account{'encid'}){ $pri_ppencid = "�@<i>��$account{'encid'}</i>"; }

	# �A�J�E���g�쐬�����ɂ��ABBS�����Ȃ�
	if($my_account->{'firsttime'} && $my_account->{'firsttime'} > 1234530536){ our $notbbs_flag = 1; }

# ���L�A�R�����g�t�H�[���Ȃǂ̃��O�ǂݍ���
my($friend_list,$friend_list2) = friendlist_prof_auth("",$file,%account);
my($diary_index,$diary_allindex,$diary_tag) = diary_prof_auth("",$file,%account);
my($bbs_index) = bbs_prof_auth("",$file,\%account);
my($line_comments) = auth_prof_comment("",$file,\%account);

my($tagline) = auth_prof_tag("",$file,%account);

# �A�J�E���g���b�N���R�A�x�����擾
my($alert_text) = auth_prof_get_alert("",%account);

# �i�r
my $clink = "$adir$file/viewcomment";

my $navilink .= qq(<a href="#PROF" class="move">���v���t�B�[��</a>);
if(our $prof_flow_flag){ $navilink .= qq((<a href="./aview-prof">�S</a>)); }
$navilink .= qq( );

if($diary_tag || $account{'myprof_flag'}){ $navilink .= qq(<a href="#DIARY" class="move">�����L</a>); }

if($account{'myprof_flag'}){ $navilink .= qq(�i<a href="$script?mode=fdiary">�V�K</a>�j); }
$navilink .= qq( );

	# �}�C���r�y�[�W�ւ̃����N
	if($friend_list){
		$navilink .= qq(<a href="./aview-friend">$main::friend_tag($account{'friend_num'})</a> );
	}


	if($account{'ocomment'} ne "3"){ $navilink .= qq(<a href="#COMMENT" class="move">���`����</a> ); }
	#if($account{'myprof_flag'} || $my_account->{'admin_flag'}){ $navilink .= qq(<a href="./edit">�ݒ�ύX</a> ); }

	if($account{'rireki_flag'}){
		my $style = qq( style="color:#aaa;") if($account{'orireki'} eq "0");
		$navilink .= qq(<a href="aview-history"$style>SNS����</a> );
	}

	if($account{'myprof_flag'} && !$account{'level2'}){
		my $link = qq($adir$my_account->{'id'}/spform);
		$navilink .= qq( <a href="$link" class="red">��SP����o�^</a>);
	}

	# �e�헚��
	if($my_account->{'admin_flag'} || $account{'myprof_flag'}){
		$navilink .= qq( <a href="${adir}aview-login-$file.html" class="red">�e�헚��</a>);
	}

	# ���ŏI���O�C�����Ԃ̕\��
	if($account{'last_access_time'}){

		# �Ǐ���
		my($allow_flag,$allow_view);

			# �\�������`�F�b�N ( �\�����Ȃ��ꍇ�𔻒� )
			if($main::myadmin_flag){ $allow_view = 1; }
					elsif($account{'allow_view_last_access'} eq "Not-open"){ }
					elsif($account{'allow_view_last_access'} eq "Friend-only"){
					if($account{'friend_status_to'} eq "friend" || $account{'myprof_flag'}){ $allow_view = 1; }
					else{ }
			}
			else{
					if($my_account->{'file'}){ $allow_view = 1; }
			}

			# �\������������ꍇ
			if($allow_view){
				my($access_time) = Mebius::SplitTime("Get-top-unit Color-view Plus-text-�O",$main::time - $account{'last_access_time'});
					if($access_time){ $navilink .= qq( �ŏI���O�C���F $access_time); }
			}

	}

# �Ǘ��҂̏ꍇ�A�e��f�[�^�擾
if($my_account->{'admin_flag'}){ ($addata) = get_addata("",$file,%account); $navilink .= $addata; }


	# �G���[��
	if($account{'key'} eq "2"){
		$error_text .= qq(���̃A�J�E���g�̓��b�N���ł� ($account{'account_locked_count'}���) );
			if($account{'blocktime'}){
				my $unblock_date = int( ($account{'blocktime'} - time) / (24*60*60) ) + 1;
				$error_text .= qq(��������$unblock_date����ł��B);
			}
			else{
				$error_text .= qq( [ ������ ] );
			}
				$error_text .= qq(�i<a href="$basic_init->{'guide_url'}%A5%A2%A5%AB%A5%A6%A5%F3%A5%C8%A5%ED%A5%C3%A5%AF">���p���`</a>�j);
			}
		if($error_text){ $error_text = qq(<strong class="red">$error_text</strong> ); } 

	# �Ǘ��҂̏ꍇ
	if($account{'admin'}){
		$member_mark .= qq(�@<a href="http://mb2.jp/_main/admins.html" class="red" title="�Ǘ���">���Ǘ���</a>);
	}

	# SP����̏�
	if($account{'level2'} >= 1){
			if($my_account->{'login_flag'}){
				$member_mark .= qq(�@<a href="$adir$my_account->{'id'}/spform" class="blue" title="SP�����o�[">��SP���</a>);
			}
			else{
				$member_mark .= qq(�@<span class="blue" title="SP�����o�[">��SP���</span>);
			}
	}

	# �������߂t�q�k
	#if($account{'myurl'}){
	#	$member_mark .= qq(�@<a href="$account{'myurl'}" title="$account{'myurl'}">��$account{'myurltitle'}</a>);
	#}

	# �}�[�N���`
	if($member_mark){
		$member_mark = qq(<span class="member_mark">$member_mark</span>);
	}


	# �g�эL��
	if($kflag){
		my($kadsense) = kadsense("OTHER");
		$print .= qq($kadsense<hr$xclose>);
	}

	# �j���[�X�t�B�[�h
	my($news);


	if($account{'question_last_post_time'}){
		$question_history = Mebius::Question::View->one_account_question(10,$account);
			if($question_history){
				$question_history = qq(<h2 id="QUESTION">�����������?</h2>) . shift_jis($question_history);
			}
	}

# HTML
$print .= our $footer_link;

$print .= qq(
<h1$kfontsize_h1>$hername</h1>
$pri_ppencid $member_mark
$error_text
<div class="navilink">$friendlink$navilink</div>
$alert_text);

	# CCC 2012/8/21 (��) - 1week
	my($q) = Mebius::query_state();
	if(time < 1345553915 + 7*24*60*60 && $my_account->{'login_flag'} && $my_account->{'file'} eq $q->param('account')){
		$print .= qq(<div class="red padding">�����m�点�c�V������<a href="./feed" class="red">�t�B�[�h�y�[�W</a>�Ɉړ����܂����B</div>);
	}


$print .= qq($profile_line
<div class="upmenu">$tagline</div>
$diary_tag
$diary_index
$diary_allindex
$bbs_index
$question_history
$friend_list2
$line_comments
);

# �ҏW�t�H�[���\��
$print .= $myform;

$print .= our $footer_link2;

# �t�b�^
Mebius::Template::gzip_and_print_all({},$print);

# �����I��
exit;
}


#-----------------------------------------------------------
# �V���}�C���r�̃g�s�b�N�X�i�����p�j
#-----------------------------------------------------------
sub defined_befriend_list{

# �錾
my($type,$file) = @_;
my($befriend_handler);
my($i,$text1,$h3,$befriend_link,$flowflag,$new_apply_num,$applty_time,$most_new_applied_time);
my($init_directory) = Mebius::BaseInitDirectory();
my($basic_init) = Mebius::basic_init();

	# �t�@�C����`
	if(Mebius::Auth::AccountName(undef,$file)){ return(); }

# �f�B���N�g����`
my($account_directory) = Mebius::Auth::account_directory($file);
	if(!$account_directory){ die("Perl Die! Account directory setting is empty."); }

# �t�@�C�����J��
open($befriend_handler,"<","${account_directory}${file}_befriend.cgi");

# �t�@�C����W�J
	while(<$befriend_handler>){

		$i++;

		$new_apply_num++;


			if($i >= 5){ next; }

		chomp;
		my($account2,$name,$applty_time2) = split(/<>/);
	
			#if(time < $applty_time2 + (3*24*60*60)){
				#$new_apply_num++;
			#	$applty_time = $applty_time2;
			#}

			# �ł��ŋ߂̐\�����Ԃ��L��
			if($applty_time2 > $most_new_applied_time){
				$most_new_applied_time = $applty_time2;
			}

		$befriend_link .= qq(<li><a href="$basic_init->{'auth_url'}$account2/">$name - ${account2}</a> �F );
		$befriend_link .= qq(<a href="$main::script?mode=befriend&amp;decide=ok&amp;account=${account2}">����</a> | );
		$befriend_link .= qq(<a href="$main::script?mode=befriend&amp;decide=no&amp;account=${account2}">����</a></li>);
			if($i >= 3){ $flowflag = 1; next; }
	}

close($befriend_handler);

	# ���o����`
	if($befriend_link) {

		$h3 = qq(<a href="./aview-befriend">�V���}�C���r�\\��</a>);

		$befriend_link = qq(
		<h3$main::kstyle_h3>$h3</h3>
		<ul>$befriend_link</ul>
		);

	}

return($befriend_link,$new_apply_num,$most_new_applied_time);

}


#-----------------------------------------------------------
# �A���[�g������ꍇ
#-----------------------------------------------------------
sub auth_prof_get_alert{

# �錾
my($type,%account) = @_;
my($alert_text,$alert_text_return);
my($init_directory) = Mebius::BaseInitDirectory();
our($css_text);

# ���^�[��

# �������Ԃ��I����Ă���ꍇ
if($account{'reason'} eq ""){ return(); }


# CSS��`
$css_text .= qq(div.alert3{background-color:#f55;color:#fff;font-weight:bold;padding:0.3em 0.5em;margin-top:1em;});

# �x�����R
require "${init_directory}part_delreason.pl";
($alert_text) = &delreason($account{'reason'},"ONLY");
my $alert_count = qq(�i�x���F$account{'alert_count'}��ځj) if($account{'alert_count'});

	# �x����������ꍇ
	if($alert_text){

			# �x�����e
			if($account{'alert_flag'}){
					if($account{'editor_flag'}){
						$alert_text_return = qq(�Ǘ��҂��烁�b�Z�[�W $alert_count (���e�͂��Ȃ������Ɍ����܂�)�F $alert_text);
					}
					else{
						$alert_text_return = qq(���̃A�J�E���g�ɂ́A�Ǘ��҂���x���������Ă��܂��B$alert_count);
					}
			}

			# �A�J�E���g���b�N���́A�S���Ƀ��b�N���R��\��
			elsif($account{'key'} eq "2"){

					# ���b�N���R��\�����Ȃ��ꍇ
					if($account{'reason'} eq "8" || $account{'reason'} eq "11"){

						if($account{'editor_flag'}){
							$alert_text_return = qq(���b�N���R�F $alert_text (���R�͂��Ȃ��ɂ����\\������Ă��܂�));
						}
						else{
							$alert_text_return = qq(���b�N���R�̎�ނ͖{�l�ɕ\\������܂�);
						}
					}
					# ���b�N���R��\������ꍇ
					#if($account{'blocktime'} >= time || !$account{'blocktime'}){
					else{
						$alert_text_return = qq(���b�N���R�F $alert_text);
					}
					#}
					

			}

	}

	# ���`
	if($alert_text_return){

			if($account{'editor_flag'}){
				$alert_text_return .= qq(<br$main::xclose><span class="size80">�������� �F ���Ȃ��̑S�Ă̓��e�̒��ŁA�K�C�h�ɔ�����Ǝv����ӏ��́A�����g�ł��폜�����肢���܂��B �s�K�؂ȕ������c�����܂܂̏ꍇ�A�A�J�E���g�̏�Ԃ��d���Ȃ�ꍇ������܂��B</span>);
			}
			#else{
			#	$alert_text_return .= qq(<br$main::xclose><span class="size80">���S�Ă̓��e�̒�����A�K�C�h�ɔ�����Ǝv����ӏ��́A�����g�ł��폜�����肢���Ă��܂��B �s�K�؂ȕ������c�����܂܂̏ꍇ�A�A�J�E���g�̏�Ԃ��d���Ȃ�ꍇ������܂��B</span>);
			#}

		$alert_text_return = qq(<div class="alert3 line-height">$alert_text_return</div>);

	}

return($alert_text_return);

}

#������������������������������������������������������������
# �}�C���r�̈ꗗ
#������������������������������������������������������������
sub friendlist_prof_auth{

# �Ǐ���
my($type,$file,%account) = @_;
my($flow,$i,$text,$friend_num,$h2_text);
our($kfontsize_h2,$friend_tag,$adir);

# �}�C���r ���X�g�̍ő�\����
my $max_viewfriend = 10;

my(%friend_index) = Mebius::Auth::FriendIndex("Get-all-index",$file);

my $friend_list = $friend_index{'topics_line'};
my $friend_list2 = $friend_index{'index_line'};

#�����N
my $link = "$adir$file/aview-friend";

	# ���`�P
	if($i){
		$h2_text = qq(<a href="$link">$friend_tag</a>);
	}	else {
		$h2_text = qq(<a href="$link">$friend_tag</a>);
	}

	if($account{'friend_num'}){ $friend_num = qq(($account{'friend_num'})); }

	# ���`�Q
	if($flow){ $friend_list .= qq(<a href="$link" class="andmore">�c���̃����o�[</a> ); }
	else{$friend_list .= qq(<a href="$link" class="andmore">���Љ</a>); }
	if($friend_list ne "") { $friend_list = qq(<div class="myfriend"><a href="$link">��$friend_tag</a> �c $friend_list</div>); }

	if($friend_list2 ne "") { $friend_list2 = qq(<h2 id="FRIEND"$kfontsize_h2><a href="$link">$friend_tag$friend_num</a></h2><div class="line-height-large">$friend_list2</div>); }


$friend_list,$friend_list2;

}


#-----------------------------------------------------------
# �v���t�B�[������
#-----------------------------------------------------------
sub auth_viewprof{

my($type,$file,%account) = @_;
my($i,$flag,$prof1,$prof2,$pri_prof);
my($kr_line,$kr_flow_flag,$birthday_text,$max1);
my($my_use_device) = Mebius::my_use_device();
our($kflag,$kfontsize_h2,$xclose);

	if($my_use_device->{'narrow_flag'}){
		$max1 = 50;
	} else {
		$max1 = 150;
	}

	# �v���t�B�[�����Ȃ��ꍇ
	if($account{'prof'} eq ""){
		$pri_prof = qq(<h2 id="PROF"$kfontsize_h2>�v���t�B�[��</h2>�v���t�B�[���͂܂�����܂���B);
			if($account{'editor_flag'}){ $pri_prof .= qq(�@<a href="./edit">�ݒ�ύX�t�H�[��</a>�ł��Ȃ��̃v���t�B�[���������Ă��������B); }
		return($pri_prof);
	}


# �v���t����ꍇ
$pri_prof .= qq(\n);

	# ���a�����̕\��
	if($account{'birthday'}){
		$main::css_text .= qq(div.birthday{padding:0.3em 0.5em;});

			if($account{'birthday_concept'} !~ /Not-open/ && ($account{'friend_status_to'} eq "friend" || $account{'myprof_flag'})){
				$birthday_text = qq($account{'birthday'} <span style="color:#080;"> [ $main::friend_tag �����ɕ\\�����Ă��܂� ] </span>);
			}
			elsif($main::myadmin_flag){
				$birthday_text = qq($account{'birthday'} <span style="color:#f00;"> [ �Ǘ��҂����ɕ\\�����Ă��܂� ] </span>);
			}
			if($birthday_text){
				$birthday_text = qq(<div class="birthday" style="background:#dee;">�a�����F $birthday_text</div><br$main::xclose>);
			}
		$pri_prof .= qq($birthday_text);
	}

# �v���t�B�[�����s���ŋ�؂�
foreach( split(/<br>/,$account{'prof'}) ){
$i++;
if($i > $max1){ $flag = 1; next; }
$_ = &auth_auto_link($_);
$pri_prof .= qq($_<br$xclose>);
}

$pri_prof .= qq(\n);

#my $zan = $i - $max;
my $zan = $i - $max1;

my($cut);
if($i > 75){ $cut = qq( class="cut_prof1"); }
else{ $cut = qq( class="prof"); }

	if($flag){
		our $prof_flow_flag = 1;
		$pri_prof .= qq(<br$xclose><a href="./aview-prof" class="prof_next">�c$max1�s�ȏ�͏ȗ�����܂�</a> <a href="./aview-prof#AVIEW" class="prof_next">��</a>);
		$pri_prof = qq(<h2 id="PROF"$kfontsize_h2><a href="./aview-prof">�v���t�B�[��</a></h2><div$cut>$pri_prof</div>);
	}
	else{
		$pri_prof = qq(<h2 id="PROF"$kfontsize_h2>�v���t�B�[��</h2><div$cut>$pri_prof</div>);
	}

# �B���֘A���v���X
if($account{'kr_flag'}){ $pri_prof .= qq($account{'kr_oneline'}); }

# �֘A�����N���I�t�̏ꍇ�͍L����\��
#elsif(!$kflag && length($account{'prof'}) >= 2*50 && !$main::alocal_mode){
#$pri_prof .= qq(
#<br$main::xclose><br$main::xclose>
#<script type="text/javascript"><!--
#google_ad_client = "pub-7808967024392082";
#/* �r�m�r�Q */
#google_ad_slot = "4618975314";
#google_ad_width = 468;
#google_ad_height = 60;
#//-->
#</script>
#<script type="text/javascript"
#src="http://pagead2.googlesyndication.com/pagead/show_ads.js">
#</script>
#);
#}

# �v���t�B�[�������G���A

$pri_prof .= qq(<div class="size90 right margin-top">);

	# �v���t�B�[���̍ŏI�ҏW����
	if($account{'last_profile_edit_time'}){
		my($how_before) = Mebius::SplitTime("Color-view Plus-text-�O Get-top-unit",$main::time - $account{'last_profile_edit_time'});
		$pri_prof .= qq( �ҏW�F $how_before );
	}

	# �ҏW�����N
	if($account{'editor_flag'}){
		$pri_prof .= qq(�@<a href="./edit#EDIT">���v���t�B�[����ҏW</a>);
	}

$pri_prof .= qq(</div>);

return($pri_prof);

}


#������������������������������������������������������������
# ���L�C���f�b�N�X
#������������������������������������������������������������
sub diary_prof_auth{

# �錾
my($type,$file,%account) = @_;
my($text1,$text2,$alldiary_num,$diary_index,$diary_allindex,$onlyflag,$diary_tag);
my($my_account) = Mebius::my_account();
my($init_directory) = Mebius::BaseInitDirectory();
our($kfontsize_h2,$xclose,$adir,$script);

	# �A�J�E���g������
	if(Mebius::Auth::AccountName(undef,$file)){ return(); }

# �f�B���N�g����`
my($account_directory) = Mebius::Auth::account_directory($file);
	if(!$account_directory){ die("Perl Die! Account directory setting is empty."); }

	# �R�����g���ݒ�̕\��
	if($account{'odiary'} eq "0"){ $text1 = qq(<em class="red">���A�J�E���g�傾�����R�����g�ł��܂�</em>); }
	elsif($account{'odiary'} eq "2"){ $text1 = qq(<em class="green">���}�C���r�������R�����g�ł��܂�</em>); }
	else{ $text1 = qq(<em>���S�����o�[���R�����g�ł��܂�</em>); }

	# �\������
	if($account{'level'} >= 1){
		if($account{'osdiary'} eq "2"){
		if($account{'friend_status_to'} ne "friend" && !$account{'myprof_flag'} && !$my_account->{'admin_flag'}){ return; }
		$text2 = qq(�@<em class="green">��$�}�C���r�����ɓ��L���J���ł�</em>);
		$onlyflag = 1;
	}
	elsif($account{'osdiary'} eq "0"){
		if(!$account{'myprof_flag'} && !$my_account->{'admin_flag'}){ return; }
		$text2 = qq(�@<em class="red">�����������ɓ��L���J���ł�</em>);
		$onlyflag = 1;
		}
	}

# ���s�C���f�b�N�X���J��
#my($index) = Mebius::SNS::Diary::index_file_per_account({ file_type => "now" } , $file);
my($now_diary_index,$diary_index_data) = Mebius::SNS::Diary::view_index_per_account({ NotControlForm => 1 , max_view_line => 10  } , "now",$file);
shift_jis($now_diary_index);
	if($now_diary_index){ $diary_index = qq($text1$text2<br$xclose><br$xclose>$now_diary_index); }

require "${init_directory}auth_diax.pl";
$diary_allindex = main::auth_all_diary_month_index(undef,$account{'id'});

	# ���܂ł̓��L�̌�
	if($diary_index_data->{'newest_diary_number'}){ $alldiary_num = qq( ($diary_index_data->{'newest_diary_number'})); }

	if($diary_allindex){ $diary_allindex = qq(<div class="scroll margin-top"><div class="scroll-element"><a href="./diax-all-new">���O</a> �F $diary_allindex</div></div>); }

	if($diary_index eq "" && $diary_allindex eq "" && $account{'myprof_flag'}) {
		$diary_tag = qq(<h2 id="DIARY"$kfontsize_h2><a href="./diax-all-new">���L</a></h2>);
		$diary_index = qq(���L�͂܂�����܂���<br$xclose>);
	}

	if($diary_index ne "" || $account{'myprof_flag'}){ $diary_tag = qq(<h2 id="DIARY"$kfontsize_h2><a href="./diax-all-new">���L$alldiary_num</a></h2>); }

	if($account{'myprof_flag'}){ $diary_tag .= qq(<a href="$script?mode=fdiary">���V�������L������</a><br$xclose><br$xclose>); }

$diary_index,$diary_allindex,$diary_tag;

}

#������������������������������������������������������������
# �a�a�r�C���f�b�N�X
#������������������������������������������������������������
sub bbs_prof_auth{

# �錾
my($type,$file,$account) = @_;
my($onlyflag,$bbs_index);
my($my_account) = Mebius::my_account();
our($kfontsize_h2,$notbbs_flag,$xclose,$adir,$yetfriend,$friend_tag);

	# �t�@�C����`
	if(Mebius::Auth::AccountName(undef,$file)){ return(); }
	
	# BBS�t���O�������Ă��Ȃ��ꍇ�́A�t�@�C�����J�����ɕ��׌y������
	if(time >= 1333597014 + 30*24*60*60 && !$account->{'use_bbs'}){
		return();
	}

	# �A�J�E���g�쐬�����ɂ��ABBS�����Ȃ�
	if($notbbs_flag && $account->{'myprof_flag'}){ return; }

# �f�B���N�g����`
my($account_directory) = Mebius::Auth::account_directory($file);
	if(!$account_directory){ die("Perl Die! Account directory setting is empty."); }

# �Ǐ���
my($text1,$text2);

	# �R�����g���ݒ�̕\��
	if($account->{'obbs'} eq "0"){ $text1 = qq(<em class="red">���A�J�E���g�傾�����R�����g�ł��܂�</em>); }
	elsif($account->{'obbs'} eq "2"){ $text1 = qq(<em class="green">��$friend_tag�������R�����g�ł��܂�</em>); }
	else{ $text1 = qq(<em>���S�����o�[���R�����g�ł��܂�</em>); }

	# �\������
	if($account->{'level'} >= 1){
			if($account->{'osbbs'} eq "2"){
			if(!$yetfriend && !$account->{'myprof_flag'} && !$my_account->{'admin_flag'}){ return; }
		$text2 = qq(�@<em class="green">��$friend_tag������BBS���J���ł�</em>);
		$onlyflag = 1;
	}
	elsif($account->{'osbbs'} eq "0"){
			if(!$account->{'myprof_flag'} && !$my_account->{'admin_flag'}){ return; }
				$text2 = qq(�@<em class="red">������������BBS���J���ł�</em>);
				$onlyflag = 1;
			}
	}

# ���s�C���f�b�N�X��ǂݍ���
my $open = open(INDEX_IN,"<","${account_directory}bbs/${file}_bbs_index.cgi");
my $top = <INDEX_IN>;
	while(<INDEX_IN>){
		my($key,$num,$sub,$res,$dates,$newtime,$restime,$resaccount,$resname) = split(/<>/,$_);
		my($year,$month,$day,$hour,$min) = split(/,/,$dates);
		my($link,$mark,$line);

		$link = qq($adir${file}/b-$num);

			if($key eq "0"){ $mark .= qq(<span class="lock"> - ���b�N��</span> ); }

		# ���ʂɕ\������
			if($key eq "0" || $key eq "1"){
			if($resaccount){ $mark .= qq( - <a href="$link#S$res">Re: $resname - $resaccount</a>); }
		#if(time < $newtime + 3*24*60*60){ $mark .= qq( - <span class="red">new!</span>); }
			if(time < $restime + 3*24*60*60){ $mark .= qq( - <span class="red">res!</span>); }
				$bbs_index .= qq(<li><a href="$link">$sub</a> ($res)$mark</li>);
			}

		# �폜�ς݂̏ꍇ
		else{
			my($text);
				if($key eq "2"){ next; $text .= qq( �A�J�E���g�ɂ��폜); }
				elsif($key eq "4"){ $text .= qq( �Ǘ��҂ɂ��폜); }
				if($my_account->{'admin_flag'}){ $text .= qq( <a href="$link" class="red">$sub</a>); }
			$bbs_index .= qq(<li>$text</li>);
		}


	}
close(INDEX_IN);

	# CCC 2012/4/5 (��)
	if($open && !$account->{'use_bbs'}){
		my %renew;
		$renew{'use_bbs'} = 1;
		Mebius::Auth::File("Renew",$account->{'id'},\%renew);
		Mebius::AccessLog(undef,"SNS-BBS-flag-stand","$account->{'id'}");
	}

	if($bbs_index){ $bbs_index = qq(<h3 id="BBS_NEW">�L���ꗗ</h3>$text1$text2<br$xclose><br$xclose><ul>$bbs_index</ul>); }

# ���x��
#my $bbs_tag = qq(<h2 id="BBS"$kfontsize_h2>BBS</h2>);
	#if($bbs_index eq "") { $bbs_tag = ""; }

	if($bbs_index) {
		$bbs_index = qq(<h2 id="BBS"$kfontsize_h2>BBS</h2>$bbs_index);
	}

$bbs_index;

}



#������������������������������������������������������������
# �`����
#������������������������������������������������������������
sub auth_prof_comment{

# �錾
my($type,$file,$account) = @_;
my($i,$index,$stop,$form,$max,$flag,$line,$text);
my($init_directory) = Mebius::BaseInitDirectory();
my($my_account) = Mebius::my_account();

# �t�@�C����`
$file =~ s/[^0-9a-z]//g;
if($file eq ""){ return(); }

# CSS��`
$main::css_text .= qq(
div.comment{width:40em;word-wrap:breal-word;line-height:1.2;}
td{padding:0.3em 0em 0.3em 0.5em;vertical-align:top;vertical-align:top;}
);

require "${init_directory}auth_comment.pl";
my($comments,$form) = view_auth_comment("PROF Get-index",$file,"",5,%$account);

# ��\���ݒ�̏ꍇ
if($account->{'ocomment'} eq "3" && !$my_account->{'admin_flag'}){ return; }

$line = qq($comments<br$main::xclose>$form);

return($line);

}



#-----------------------------------------------------------
# �}�C�^�O�擾
#-----------------------------------------------------------
sub auth_prof_tag{

# �Ǐ���
my($type,$file,%account) = @_;
my($init_directory) = Mebius::BaseInitDirectory();
my($my_use_device) = Mebius::my_use_device();
my($tagline,$max_view_tag_num,$nextlink,$i);
our($adir);

	# �^�O�̍ő�\����
	if($my_use_device->{'smart_flag'}){
		$max_view_tag_num = 16;
	} else {
		$max_view_tag_num = 16;
	}

# �f�B���N�g����`
my($account_directory) = Mebius::Auth::account_directory($file);
	if(!$account_directory){ die("Perl Die! Account directory setting is empty."); }

# �}�C�^�O�t�@�C�����J��
open(MYTAG_IN,"<","${account_directory}${file}_tag.cgi");
	while(<MYTAG_IN>){
		my($key,$tag) = split(/<>/,$_);
		if($key ne "1"){ next; }
		$i++;
		if($i > $max_view_tag_num){ $nextlink = qq(<a href="$adir$file/tag-view" class="andmore">�c����������</a>); last; }
		if($i > 1){ $tagline .= qq(); }
		my $enctag2 = $tag;
		$enctag2 =~ s/([^\w])/'%' . unpack("H2" , $1)/eg;
		$enctag2 =~ tr/ /+/;
		$tagline .= qq(<a href="${adir}tag-word-${enctag2}.html">$tag</a> );
	}
close(MYTAG_IN);

	# ���`
	if($tagline eq ""){
		$tagline = qq(���^�O�͂܂�����܂���B);
			if($account{'myprof_flag'}){ $tagline .= qq(�i<a href="$adir$file/tag-view">���^�O��o�^����</a>�j); }
	}
	else{
		$tagline .= $nextlink;
	}

$tagline = qq(<div class="tag scroll"><div class="scroll-element">�^�O �F $tagline</div></div>);

$tagline;

}

#-----------------------------------------------------------
# �Ǘ��҂ɂ���������f�[�^�擾
#-----------------------------------------------------------

sub get_addata{

# �錾
my($type,$file,%account) = @_;
my($top,$login_date,$addata);
my($my_account) = Mebius::my_account();
our($css_text);

	# �A�J�E���g������
	if(Mebius::Auth::AccountName(undef,$file)){ return(); }

# CSS��`
our $css_text .= qq(\ndiv.addata{background-color:#ff0;margin-top:1em;padding:0.4em 0.9em;line-height:1.4;});

# ���O�C���������J��
my(%login) = Mebius::Login->login_history("Onedata Admin",$file);
($login_date) = Mebius::Getdate("",$login{'lasttime'});

# �����f�[�^���J��
#open(FIRST_IN,"${account_directory}${file}_first.cgi");
#$top = <FIRST_IN>; chomp $top;
#my($time2,$date2,$xip2,$host2,$age2,$cnumber2) = split(/<>/,$top);
#close(FIRST_IN);

# �o�^��
my($first_date) = Mebius::Getdate("",$account{'firsttime'});

# ���[�_�[�ȏ�ɕ\��
my($enccnumber) = Mebius::Encode("",$login{'cnumber'});

$addata .= qq(<div class="addata">);

$addata .= qq(�o�^���F $first_date �ŏI���O�C���F $login_date );
$addata .= Mebius::Admin::user_control_link_cookie($login{'cnumber'}) . " - ";

	# �}�X�^�[�ɕ\��
	if($my_account->{'admin_flag'} >= 5){
		$addata .= Mebius::Admin::user_control_link_host($login{'host'}) . " - " ;
		$addata .= Mebius::Admin::user_control_link_user_agent($login{'agent'});
	}

$addata .= qq(</div>);

$addata;

}

1;

