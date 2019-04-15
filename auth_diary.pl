
use strict;
use Mebius::SNS::Crap;
use Mebius::SNS::Diary;
use Mebius::Text;
use Mebius::Report;
use Mebius::Device;
use Mebius::Mode;

package main;
use Mebius::Export;


#-----------------------------------------------------------
# ���L�\��
#-------------------------------------------------
sub auth_diary{

# �Ǐ���
my $diary_object = new Mebius::SNS::Diary;
my($my_use_device) = Mebius::my_use_device();
my($basic_init) = Mebius::basic_init();
my($my_account) = Mebius::my_account();
my($parts) = Mebius::Parts::HTML();
my($param) = Mebius::query_single_param();
my($submode) = Mebius::Mode::submode();
my $ads = Mebius::Ads->new();
my($form,$deleted_flag,$adsflag,$text1,$iline);
my($diary_handler,%account,$control_mode,$control_flag,$maxview_res,$diary_line,$form,$adsflag1,$adsflag2,$noads_flag_judge_comment_and_subject,$noads_mode,$ads_first_view,$res_line,$cuted_res_line,$account,$h1_diary_subject,$hit_res,$zero_res_line);
my $package = new Mebius::SNS::Diary;
my $sns_account = new Mebius::SNS::Account;

our($adir,$device_type,$kfontsize_h1,$kfontsize_h2,$kfontsize_small,$script,$khrtag,$backurl_query_enc,$yetfriend);

# �ᔽ�񍐃��[�h
Mebius::Report::report_mode_junction({ BBS => 1 });

	# �R���g���[����p���[�h���`
	if($submode->{'3'} eq "all"){ $control_mode = 1; }

# ��`
our $auth_diary_maxmsg = 2500;

	# �P�L��������̃��X�̍ő�\����
	if(Mebius::Device::use_device_mobile_judge()){ $maxview_res = 10; }
	else{ $maxview_res = 50; }

# �b�r�r��`
$main::css_text .= qq(
textarea{width:95%;height:200px;}
.ads_right{width:170px;padding-left:2em;}
.diary_ads{margin-top:1em;}
.ads_first_view{border-top:1px solid #000;padding:1em 0em 0em 0em;margin-top:1em;}
.date{text-align:right;}
.maxmsg{color:#080;font-size:90%;}
.deleted{color:#f00;font-size:120%;}
.cdeleted{color:#f00;font-size:80%;}
div.admin_deleted{background:#fee;color:#999;}
.diary_index{font-size:90%;line-height:1.4;}
.me{font-weight:bold;}
h1{color:#080;}
p.s{line-height:1.4;}
div.res_control{text-align:right;margin-top:0.5em;}
a.delete_mode{color:#666;}
div.crap_line{font-size:90%;word-spacing:0.5em;}
div.under_main_diary{border-bottom:dashed 1px #000;padding:0.5em 0.5em 1.0em 0.5em;}
);
	if($ENV{'USER_AGENT'} =~ /MSIE 8.0/){ $main::css_text .= qq(.textarea{width:700px;}); }

	if($my_use_device->{'smart_phone_flag'}){
		$main::css_text .= qq(.body1{width:100%;});
	}

# �����`�F�b�N�P
	if(Mebius::Auth::account_name_error($param->{'account'})){
		&error("�J���A�J�E���g���w�肵�Ă��������B");
	} else {
		$account = $param->{'account'};
	}

# �����`�F�b�N�Q
my $diary_number = $submode->{'2'};
$diary_number =~ s/\D//g;
	if($diary_number eq ""){ &error("�J���t�@�C�����w�肵�Ă��������B"); }

# �f�B���N�g����`
my($account_directory) = Mebius::Auth::account_directory($account);
	if(!$account_directory){ die("Perl Die! Account directory setting is empty."); }

# �����`�F�b�N�Q
my $resnum = $submode->{'3'};
$resnum =~ s/\D//g;

# �v���t�B�[�����J��
(%account) = Mebius::Auth::File("Hash Kr-submit Kr-oneline Option",$account);

	# ���b�N���̃A�J�E���g�ł͍L�����\����
	if($account{'key'} eq "2" || $account{'alert_flag'}){ $noads_mode = 1; }

	# ���[�U�[�F�w��P
	if($account{'color1'}){
		$main::css_text .= qq(h2{background-color:#$account{'color1'};border-color:#$account{'color1'};});
	}

	# ���[�U�[�F�w��Q
	if($account{'color2'} && $account{'color2'} ne "000"){
		$main::css_text .= qq(
		a.me:link{color:#$account{'color2'};}
		a.me:visited{color:#$account{'color2'};}
		);
	}
	else{
		$main::css_text .= qq(
		a.me:link{color:#f00;}
		a.me:visited{color:#f40;}
		);
	}

# �}�C���r��Ԏ擾
&checkfriend($account);

	# ���L�\���̐���
	if($account{'level'} >= 1){
			if($account{'osdiary'} eq "2"){
			if(!$yetfriend && !$account{'myprof_flag'} && !$my_account->{'admin_flag'}){ &error("���L�����݂��܂���B"); }
		$text1 = qq(<em class="green">���}�C���r�����ɓ��L���J���ł�</em><br><br>);
		$noads_mode = 1;
	}
	elsif($account{'osdiary'} eq "0"){
			if(!$account{'myprof_flag'} && !$my_account->{'admin_flag'}){ &error("���L�����݂��܂���B"); }
				$text1 = qq(<em class="red">�����������ɓ��L���J���ł�</em><br><br>);
				$noads_mode = 1;
			}
	}


# ���L�t�@�C�����J��
my($diary) = Mebius::SNS::Diary::thread_file($account,$diary_number);
	if(!$diary->{'f'}){
		main::error("���L�����݂��܂���B");
	}

$diary_object->read_on_history($diary);

# BCL�����N�𑁑���`
my @BCL;
push @BCL, { url => "./" , title => $account{'name'} };
push @BCL, { url => "./diax-all-new" , title => "���L" };
push @BCL, $diary->{'subject'} ;

	# ���e�ɂ���čL�����\����
	if($diary->{'key'} ne "1"){ $noads_mode = 1; }
	if(Mebius::Report::report_mode_judge()){ $noads_mode = 1; }
	if(Mebius::Fillter::ads(undef,utf8_return($diary->{'subject'}),utf8_return($diary->{'res_data'}->[0]->{'comment'}))){ $noads_mode = 1; } # ���L�̑薼�ƁA0�Ԃ̖{����
	my($subject_fillter_error) = Mebius::Fillter::fillter_and_error(utf8_return($diary->{'subject'}),utf8_return($diary->{'res_data'}->[0]->{'comment'}));

	# �����L�{�̂��폜�ς݂̏ꍇ
	if($diary->{'deleted_flag'}){

		# �폜���
		my $deleter = $diary->{'control_account'};
			if($deleter){
				my($account_url) = Mebius::SNS::Path->account_url($diary->{'control_account'});
				$deleter = qq(�폜�ҁF <a href=").e($account_url).q(">).e($deleter).q(</a>);
				my($delete_time_how_long) = shift_jis(Mebius::second_to_howlong({ TopUnit => 1 } , time - $diary->{'control_time'} )) if($diary->{'control_time'});
				$deleter .= qq( �폜���ԁF ) . e($delete_time_how_long).q(�O);
			}

		my $message = qq(���̓��L�͍폜�ς݂ł��B $deleter);

			# �Ǘ��҂̏ꍇ
			if($my_account->{'admin_flag'}) {
				$deleted_flag .= qq(<strong class="deleted">);
				$deleted_flag .= qq(���̓��L�͍폜�ς݂ł��i�Ǘ��҂̂݉{���\\�j $deleter);
					if($diary->{'penalty_done'}){ $deleted_flag .= qq( �y�i���e�B���� ); }
				$deleted_flag .= qq($diary->{'control_datas'}</strong><br><br>);
				$noads_mode = 1;

			# �����̏ꍇ
			}	elsif(Mebius::SNS::Diary::allow_user_revive_judge($account,$diary)){
				my($parts) = shift_jis(Mebius::SNS::Diary::thread_control_form($account,$diary));
				$message .= q(<hr><h2>����</h2>);
				$message .= $parts;
				Mebius::Template::gzip_and_print_all({ BodyPrint => 1 , BCL => \@BCL },$message);
				exit;
			} else {
				main::error($message,"410 Gone"); 
			}

	}

# �㕔�i�r�����N
my $link1 .= $text1;
$link1 .= $deleted_flag;
$link1 .= qq(<a href="$adir${account}/">�v���t�B�[����</a> - );
$link1 .= qq(<a href="$adir$account/diax-all-new">�S���L</a> - );
$link1 .= qq(<a href="$adir$account/diax-$diary->{'year'}-$diary->{'month'}">$diary->{'year'}�N$diary->{'month'}���̓��L</a>);

	# �񍐃{�^��
	#if(Mebius::alocal_judge() ){
		my($move_to_report_mode_button) = shift_jis(Mebius::Report::move_to_report_mode_button({ ViewResReportButton => $diary->{'res'} }));
		$link1 .= qq( - $move_to_report_mode_button);
	#} else {
	#	$link1 .= qq( - <a href="$basic_init->{'guide_url'}%BA%EF%BD%FC%B0%CD%CD%EA%A1%CA%A5%E1%A5%D3%A5%EA%A5%F3%A3%D3%A3%CE%A3%D3%A1%CB">�폜�˗�����</a>);
	#}

# �����ˁI 
my($crap_line) = Mebius::SNS::Diary::crap_line($diary_number,$diary,\%account);

	# �X�}�t�H�p�̃t�@�[�X�g�r���[�L��
	if($noads_mode){
				if($my_use_device->{'smart_phone_flag'}){
				my($ads_first_view) = $ads->rakuten_smart_phone_widget();
				$zero_res_line .= qq(<hr>$ads_first_view);
			}

	} else {
		my($ads_first_view) = shift_jis(Mebius::SNS::Diary::ads_first_view());
		$zero_res_line .= $ads_first_view;
	}

# �[���ԓ��e�G���A
my @res_data = @{$diary->{'res_data'}};
my @res_data_with_handle = @{$sns_account->add_handle_to_data_group(\@res_data)};

my $zero_res_data = shift @res_data_with_handle;
my($zero_res_line_core) = shift_jis(Mebius::SNS::Diary::view_zero_res({ no_ads_mode => $noads_mode , crap_line => $crap_line },$account,$diary,$zero_res_data));
$zero_res_line .= $zero_res_line_core;

	# ���L���̕\��
	{

		my($ads_up,$ads_right);

			if($noads_mode){
				$ads_up = $ads->rakuten_basic_widget();
			} else {
				($ads_up) = shift_jis(Mebius::SNS::Diary::ads_up());
			}

			$zero_res_line .= $ads_up;

			# �L���p�̃e�[�u�� ( �� )
			if(!$my_use_device->{'smart_flag'} && !$my_use_device->{'mobile_flag'}){

					if($noads_mode){
						($ads_right) = $ads->rakuten_vertical_widget();
					} else {
						($ads_right) = shift_jis(Mebius::SNS::Diary::ads_right());
					}

				$zero_res_line = qq(<table style="width:100%;"><tr><td class="valign-top">$zero_res_line</td><td class="valign-top ads_right">$ads_right</td></tr></table>);
			}

	}


	# ���S�Ẵ��X��W�J
	foreach my $data (@res_data_with_handle){

		# �Ǐ���
		my($delete_input,$deleted,$class,$rescontrol_box,$divclass,$style);

		# �Ō�̃��X�̏ꍇ
		my $last_res_flag = 1 if($data->{'res_number'} == $diary->{'res'});

		$iline++;

			# �ʂ̃��X�\�����[�h
			if($resnum ne "" && $data->{'res_number'} ne $resnum){ next; }

			# ���ׂĕ\�����[�h
			if($iline != 1 && $iline <= $diary->{'res'} - $maxview_res + 1 && $submode->{'3'} ne "all"){ next; }

		$hit_res++;

			my($view_res_line,$control_flag_buf) = Mebius::SNS::Diary::view_res_core({ DbiHandle => 1 , NoAds => $noads_mode , last_res_flag => $last_res_flag , select_res_number => $submode->{'3'} ,  max_res_number => $diary->{'res'}  } , $account,$diary_number,$data);

			shift_jis($view_res_line);
			$res_line .= $view_res_line;

				if($control_flag_buf){
					$control_flag = 1;
				}

				# ��؂��
				if($hit_res >= 1 && $data->{'res_number'} ne $diary->{'res'}){ $res_line .= qq(<hr>\n); }

	}

	# �R���g���[���t�H�[�����`
	if(!Mebius::Report::report_mode_judge()){

			if(($my_account->{'admin_flag'} || ($control_mode && $my_account->{'login_flag'} && $control_flag))){

				my($backurl_input) = Mebius::back_url_hidden();
				my $submit_button;

					# �X�g�b�v���[�h
					if($main::stop_mode =~ /SNS/){
						$submit_button = qq(<input type="submit" value="SNS�͌��݁A�X�V��~���ł��B"$main::parts{'disabled'}>);
					} elsif(!$control_flag){
						0;
					} else {
						$submit_button = qq(<input type="submit" value="��������s����">);
					}


				$res_line = qq(
				$res_line
				$backurl_input
				<div class="res_control">
				$submit_button
				</div>
				);

			}

			# �R���g���[���t�H�[���ւ̈ړ������N
			elsif($my_account->{'login_flag'} && !$control_mode){
				$res_line = qq($res_line <div class="res_control"><a href="./d-$diary_number-all" class="delete_mode">�i���폜���[�h�ֈړ��j</a></div>);
			}

			# �ŏI���e���̍L��
			if($hit_res >= 1 && !$noads_mode){
				my($ads_bottom) = shift_jis(Mebius::SNS::Diary::ads_bottom());
				$res_line .= $ads_bottom;
			}

	}

	# �R�����g�t�H�[���E�񍐃t�H�[�����`
	if(Mebius::Report::report_mode_judge()){
		($res_line) = Mebius::Report::around_report_form($res_line,"sns_diary_${account}_${diary_number}");
	} else { 
		($form) = auth_diary_resform("",$account,$diary_number,$diary->{'key'},%account);
	}

	# ���X���ȗ�����Ă���ꍇ
	if($diary->{'res'} > $maxview_res && $submode->{'3'} ne "all"){
		my $cut = $diary->{'res'} - $maxview_res;
		my $link = "$adir$account/d-$diary_number-all";
		$cuted_res_line = qq(�i <a href="$link">${cut}���̃��X���ȗ�����Ă��܂�</a> �j<br><br>);
	}

# ���ʃC���f�b�N�X���擾
my($diary_month_index) = auth_diary_monthindex("",$account,$diary->{'year'},$diary->{'month'},$diary_number,\%account);


# �R�����g�G���A�̌��o��
my $comment_area_title = qq(<h2$kfontsize_h2>�R�����g</h2>) if($hit_res >= 1);

	# ���o���������N���邩���Ȃ������`
	if(Mebius::Query::get_method_judge() && (Mebius::request_url()) =~ /d-[0-9]+$/){
		$h1_diary_subject = e($diary->{'subject'}).q( - ���L);
	} else {
		$h1_diary_subject = qq(<a href=").e($diary->{'url'}).q(">).e($diary->{'subject'}).q( - ���L</a>);
	}


# �t�H�[���ň͂߂镔��
my $diary_body_line = qq(
$zero_res_line
$diary_month_index
$comment_area_title
$cuted_res_line
$res_line
);

	if(!Mebius::Report::report_mode_judge()){
		($diary_body_line) = shift_jis(Mebius::SNS::Diary::thread_control_form_around({ NotButton => 1 },utf8($diary_body_line)));
	}

	if($subject_fillter_error){
		my($subject_fillter_error_shift_jis) = shift_jis_return($subject_fillter_error);
		$subject_fillter_error = qq(<strong class="red">��).$subject_fillter_error_shift_jis.q(</strong>);
	}

$diary_line .= qq(
<h1$kfontsize_h1>$h1_diary_subject</h1>
$subject_fillter_error
<div$kfontsize_small class="scroll">$link1</div>
$khrtag
$diary_body_line
);


# �^�C�g����`
my $sub_title = qq($diary->{'subject'} | $account{'name'} �̓��L);
$sub_title = qq($diary->{'subject'} No.$submode->{'3'}) if($submode->{'3'} ne "");


# HTML
my $html = qq(
$main::footer_link

$diary_line

$form
$main::footer_link2
);

$html .= shift_jis($package->push_good_javascript());

Mebius::Template::gzip_and_print_all({ no_ads_flag => $noads_mode , BeforeUnload => 1 , Title => $sub_title , BCL => \@BCL , Jquery => 1  },$html);

exit;

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub auth_diary_response_form_core{

my $account = shift;
my $diary_number = shift;
my $comment = shift;
my($print);
my $history = new Mebius::History;
our($sikibetu,$auth_url,$wait_text);

$print .= qq(
<form action="$auth_url" method="post"$sikibetu>
<div>

$wait_text
<textarea name="comment" class="dtextarea" cols="25" rows="5">$comment</textarea>

<br><br><input type="submit" name="preview" value="���̓��e�Ńv���r���[����" class="ipreview">
<input type="submit" value="���̓��e�ő��M����" class="isubmit">);

$print .= " " . shift_jis($history->tell_my_friends_input_tag());
#$form .= qq(<strong class="maxmsg">( �S�p$auth_diary_maxmsg�����܂ŁB<a href="${adir}aview-allresdiary.html" class="blank" target="_blank">�V�����X</a>���L�^����܂��B )</strong>
$print .= qq(<input type="hidden" name="mode" value="resdiary">
<input type="hidden" name="account" value="$account">
<input type="hidden" name="num" value="$diary_number">
<br><br>
</div>
</form>
);

$print;

}

no strict;

#-------------------------------------------------
# ���L�̃R�����g�t�H�[��
#-------------------------------------------------
sub auth_diary_resform{

# �Ǐ���
my($type,$file,$diary_number,$key,%account) = @_;
my($stop,$wait_text,$form);
my($my_account) = Mebius::my_account();
my $history = new Mebius::History;
our($selfurl_enc,$kfontsize_h2);

# �X�g�b�v���[�h
if($main::stop_mode =~ /SNS/){ return(qq($khrtag<h2$kfontsize_h2>�R�����g�t�H�[��</h2>���݁ASNS�ւ̓��e�͒�~���ł��B)); }

	# �҂����ԕ\��
	if(time < $main::myaccount{'next_comment_time'}){
		my($next_splittime) = Mebius::SplitTime(undef,$main::myaccount{'next_comment_time'} - $main::time);
		$wait_text = qq(<br>�����݃`���[�W���Ԓ��ł��B����$next_splittime�ŏ������߂܂��B);
	}

	# �R�����g�ۂ̔���
	if($account{'key'} eq "2"){ $form .= qq(���A�J�E���g�����b�N���̂��ߏ������߂܂���<br><br>); $stop = 1; }
	elsif($account{'let_flag'}){ $form .= qq(��$account{'let_flag'}); $stop = 1; }
	elsif($denyfriend){ $form .= qq(���֎~�ݒ蒆�̂��߃R�����g�ł��܂���B<br><br>); $stop = 1; }
	elsif($account{'odiary'} eq "0"){
		$form .= qq(���A�J�E���g�傾�����R�����g�ł��܂��B<br><br>);
			if(!$account{'myprof_flag'}){ $stop = 1; }
	}
	elsif($key eq "0"){ $form .= qq(�����̓��L�̓R�����g���b�N���̂��߁A�������߂܂���B<br><br>); $stop = 1; }
	elsif($account{'odiary'} eq "2"){
		$form .= qq(���}�C���r�������R�����g�ł��܂��B<br><br>); 
			if(!$yetfriend && !$account{'myprof_flag'}){ $stop = 1; } 
	}

	# �Ǘ��҂̏ꍇ
	if($my_account->{'admin_flag'}){ $stop = ""; }

	# �M�����ݒ�̏ꍇ
	if($res >= $maxres_diary){ $form = qq(���R�����g�������ς��ł��B�i$maxres_diary���j<br><br>); $stop = 1; }
	elsif(!$my_account->{'login_flag'}){ $form = qq(���R�����g����ɂ�<a href="$auth_url?backurl=$selfurl_enc">���O�C���i�܂��͐V�K�o�^�j</a>���Ă��������B<br><br>); $stop = 1; }
	elsif($birdflag){ $form = qq(���R�����g����ɂ�<a href="$auth_url$my_account->{'id'}/#EDIT">���Ȃ��̕M��</a>��ݒ肵�Ă��������B<br><br>); $stop = 1; }

# �R�����g�t�H�[�����o��
$form = qq($khrtag<h2$kfontsize_h2>�R�����g�t�H�[��</h2>$form);

	# �t�H�[����`
	if(!$stop){
			$form .= auth_diary_response_form_core($file,$diary_number);
	}

return($form);

}

#-------------------------------------------------
# �����̓��L�ꗗ
#-------------------------------------------------
sub auth_diary_monthindex{

my($type,$file,$pageyear,$pagemonth,$pagenum) = @_;
my($i,$flows,$month_index_handler,$diary_index,$hit);

# �f�B���N�g����`
my($account_directory) = Mebius::Auth::account_directory($file);
	if(!$account_directory){ die("Perl Die! Account directory setting is empty."); }

# �C���f�b�N�X��ǂݍ���
open($month_index_handler,"<","${account_directory}diary/${file}_diary_${pageyear}_${pagemonth}.cgi");

	while(<$month_index_handler>){
		my($key,$num,$sub,$res,$dates,$newtime) = split(/<>/,$_);
		$i++;
				if($i >= 10){ $diary_index .= qq( <a href="diax-${pageyear}-${pagemonth}">�c</a> ); last; }
		my $link = qq(${adir}${file}/d-$num);
				if($key eq "1" || $key eq "0"){
			$hit++;
				if($hit >= 2){ $diary_index .= qq( - ); };
				if($num eq $pagenum){ $diary_index .= qq($sub); }
				else{ $diary_index .= qq(<a href="$link">$sub</a>); }
		}
	}
close($month_index_handler);

	# ���e������ꍇ
	if($diary_index){
		$diary_index = qq($khrtag<h2$kfontsize_h2>$pageyear�N$pagemonth���̓��L</h2><div class="diary_index scroll"$kfontsize_small><div class="scroll-element">$diary_index</div></div>);
	}

return($diary_index);

}




1;
