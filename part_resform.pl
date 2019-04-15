
use strict;
use Mebius::Paint;
use Mebius::BBS;
use Mebius::History;
use Mebius::Text;

package main;
use Mebius::Export;

#-----------------------------------------------------------
# �f���̓��e�t�H�[��
#-----------------------------------------------------------
sub bbs_thread_form{

# �錾
my($use) = @_;
my($my_account) = Mebius::my_account();
my($my_use_device) = Mebius::my_use_device();
my($my_real_device) = Mebius::my_real_device();
my($init_directory) = Mebius::BaseInitDirectory();
my($basic_init) = Mebius::basic_init();
my($init_bbs) = Mebius::BBS::init_bbs_parmanent_auto();
my($my_cookie) = Mebius::my_cookie_main_logined();
my($parts) = Mebius::Parts::HTML();
my $query = new CGI;
my $time = time;
my $use_thread = $use->{'use_thread'};
my $main_thread = $use->{'main_thread'};
my $sub_thread = $use->{'sub_thread'};
my $res = $use_thread->{'res'};
my $key = $main_thread->{'key'};
my($line,$submit,$textarea_input,$navi_links2,$return,$next_resnumber,$other_name_inputs,$textarea);
my($i_names,$preview_button_title);
my($finput_color,$finput_name,$finput_res,$finput_pre_res,$finput_access_time,$finput_news,$finput_up,$finput_pre_res,$finput_sub);
my($param) = Mebius::query_single_param();
my($my_admin) = Mebius::my_admin();
our($com_txt,$css_text,%in,$concept,$textarea_first_input,$concept,$stop_regist_mode,$caccount_link,$cookie,@javascript_files);
our($m_max,$moto,$formtype,$title,$xclose,$sikibetu,$input_upload,$subtopic_link,$subtopic_mode,$realmoto,$wait_textarea,$viocheck,$sexcheck);

# CSS��`
$css_text .= qq(
td.alert,td.alert2{font-size:90%;border-style:none;color:#f00;padding:0em 0em 0.5em 0em;}
td.alert2{font-size:120%;}
.ip_alert{font-size:90%;padding:0.3em;color:#f00;}
td.ip_alert{padding-bottom:0.5em;}
div.resform{margin:0em;}
.no2{text-align:center;}
);

	if($use->{'Preview'}){

		# CSS��`
		$css_text .= qq(
		.middle{color:#f00;font-size:130%;}
		.mada{color:#03f;font-weight:normal;font-style:italic;font-size:100%;}
		.please_text1{color:#080;font-size:110%;}
		.sexvio{color:#f00;font-size:90%;font-weight:bold;}
		div.special_error{background:#fcc;padding:0.7em 1em;color:#f00;line-height:2.0em;}
		div.error_line{background:#ffeaea;padding:0.7em 1em;color:#f00;line-height:2.0em;}
		div.data_line{background:#9fa;padding:0.4em 0.7em;color:#051;line-height:1.8em;}
		div.preview_line{background:#ddf;padding:0.4em 1.0em;color:#00f;}
		div.paint_image{margin:0.5em 0em 0em 0em;}
		);

		# CSS��` ( ���̏����Ƃ̋��ʕ��� )
		$css_text .= qq(
		input.wait_input{color:#f00 !important;}
		table.table2{width:100%;margin-bottom:1em;}
		th.td0{width:0%;}
		th.td1{width:50%;}
		th.td2{width:21%;}
		th.td3{width:21%;}
		th.td4{width:8%;white-space:nowrap;}
		);
	}

	if($init_bbs->{'concept'} =~ /Chat-mode/){
		$css_text .= qq(.chat_input{width:80%;});
	}

	# �������̓`�F�b�N ( �v���r���[�̏ꍇ )
	if($use->{'Preview'}){
		$textarea_input = $in{'comment'};
		$finput_color = $in{'color'};
			if($in{'other_name'}){
				$finput_name = $in{'other_name'};
			} else {
				$finput_name = $in{'name'};
			}

		$finput_res = $in{'res'};
		$finput_pre_res = $in{'pre_res'};
		$finput_access_time = $in{'access_time'};

	} elsif($use->{'inputed'}){
		$textarea_input = $use->{'inputed'}->{'comment'};
		$finput_color = $use->{'inputed'}->{'color'};
		$finput_name = $use->{'inputed'}->{'name'};
	}	else {
	# �������̓`�F�b�N ( ���̑��̏ꍇ )
			if(!Mebius::Admin::admin_mode_judge()){
				$textarea_input = $init_bbs->{'textarea_first_input'};
			}
		$finput_color = $my_cookie->{'font_color'};
		$finput_name = $my_cookie->{'name'};
		$finput_res = $in{'no'};
		$finput_pre_res = $res;
		$finput_access_time = time;
	}


# �����`�F�b�N
$finput_res =~ s/\D//g;

# ���͐��`
$textarea_input =~ s/<br$xclose>/\n/g;
$finput_sub = $in{'sub'};

	# �������j���[�����N���`
	if($use->{'GetMode'}){
		my($plus_type);
		my $move_side_links_flag = 1 if($main::mode eq "view" && !$main::subtopic_mode);
		($navi_links2) = shift_jis(Mebius::BBS::thread_navigation_links($use_thread,{ Bottom => 1 , MoveSideLinks => $move_side_links_flag }));
	}

	# ���ԑтœ��e�֎~
	#if($type =~ /RES/){ ($line) .= &thread_deny_hour(); }

	# �t�H�[����
	if($use->{'GetMode'} && $use->{'ResMode'}){

		# �X�g�b�v���[�h
		if(Mebius::Switch::stop_bbs()){
			$line .= qq(<div class="thread_status"><a href="$basic_init->{'guide_url'}" class="white">���̌f���͓��e��~���ł��B</a></div>\n);
			$return = 1;
		}
		elsif($use_thread->{'lock_flag'}) {
			require "${init_directory}part_thread_status.pl";
			my($alert_line) = thread_status_lock("LOCK DESKTOP",$main_thread->{'delete_data'},$main_thread->{'lock_end_time'});
				if($alert_line){
					$line .= qq($alert_line\n);
					$return = 1;
				}
		}
		elsif($key eq '7') { $line .= qq(<div class="thread_status"><a href="$basic_init->{'guide_url'}" class="white">���̋L����$title�̃��j���[����폜�ς݂ł��B</a></div>\n); $return = 1; }
		elsif($key == 3){ $line .= qq(<div class="thread_status">���̋L����<a href="./" class="white">$title</a>��<a href="past.html" class="white">�ߋ����O</a>�ł�</div>); $return = 1; }
		elsif($key == 2){ $line .= qq(<div class="thread_status">�Ǘ��҂���̂��m�点�ł��B</div>); $return = 1; }
		elsif($m_max <= $res){ $line .= qq(<div class="thread_status">���X��$m_max���𒴂��܂����B</div>\n); $return = 1; }
		elsif($res > ($m_max * 0.9)){
			$line .= qq(<div class="thread_status">���X��$res������܂��B$m_max�����z����ƋL�����I�����܂��B\n);
			$line .= qq(</div>);
		}
		elsif($subtopic_mode && $sub_thread->{'key'} eq "0"){ $line .= qq(<div class="thread_status">���̃T�u�L���ɂ͏������߂܂���B</div>); $return = 1; }
		elsif($concept =~ /Not-regist/){ $line .= qq(<div class="thread_status">���̌f���͓��e��~���ł��B</div>); $return = 1; }
		elsif($stop_regist_mode){ $line .= qq(<div class="thread_status">���݁A���e���󂯕t���Ă��܂���B</div>); $return = 1; }
		elsif($key == 4){ $return = 1; }

	}

	# ���e�t�H�[����\�����Ȃ��ꍇ
	if($use->{'GetMode'}){
			if($use->{'ResMode'}){ $line .= qq($navi_links2); }
			if($use->{'ResMode'} && !$return){ $line .= qq(); }
			if($return){ $line .= qq(</div>); return($line); }
	}

# ���e���̒���
my($alert_text,$under_alert) = bbs_threadform_alert($_[0],$main_thread,$sub_thread);

	# �摜�Y�t�G���A
	if($init_bbs->{'concept'} =~ /Upload-mode/){ require "${init_directory}part_upload.pl"; &upload_setup(); }

	# ���M�p�A���݂̃��X��
	if($in{'resnum'}){ $next_resnumber = $in{'resnum'}; }
	else{ $next_resnumber = $res + 1; }

	# �t�H�[�����i�n�܂�
	if(!$use->{'NotSetFormTag'}){
		my $action;
		my $bbs = Mebius::BBS->new();
			if(Mebius::Admin::admin_mode_judge()){
				$action = $bbs->true_bbs_kind() . ".cgi";
			} else {
				$action = "./";
			}

		$line .= qq(<form action=").e("$action#RESFORM").qq(" method="post" name="RESFORM" id="RESFORM"$formtype$sikibetu>\n);
	}

# �t�H�[���J�n
$line .= qq(<div class="thread_form bbs_border">\n);

	# ���t�H�[����Hidden�l
	if($use->{'EditMode'}){
		$line .= qq(<input type="hidden" name="mode" value="regist_resedit">\n);
		$line .= qq(<input type="hidden" name="moto" value=").e($realmoto).qq(">\n);
		$line .= qq(<input type="hidden" name="res" value=").e($in{'res'}).qq(">\n);
		$line .= qq(<input type="hidden" name="no" value=").e($in{'no'}).qq(">\n);
		$line .= qq(<input type="hidden" name="action" value="1">\n);
	} else {
		#$line .= qq(<input type="hidden" name="mode" value="regist">\n);
		$line .= qq(<input type="hidden" name="mode" value="regist">\n);
		#$line .= qq(<input type="hidden" name="type" value="regist">\n);
		$line .= qq(<input type="hidden" name="moto" value=").e($realmoto).qq(">\n);
		$line .= qq(<input type="hidden" name="resnum" value=").e($next_resnumber).qq(">\n);
		$line .= qq(<input type="hidden" name="no" value=").e($param->{'no'}).qq(">\n);
		$line .= qq(<input type="hidden" name="No" value=").e($param->{'No'}).qq(">\n);
		$line .= qq(<input type="hidden" name="pre_res" value=").e($finput_pre_res).qq(">\n);
		$line .= qq(<input type="hidden" name="access_time" value=").e($finput_access_time).qq(">\n);
	}

	# ���e�{�^��
	if($use->{'ResMode'}) {
		my($mark);
		$mark = qq( �h�{�ҁh ��) if($subtopic_link);
		$mark = qq( �h�R�����g�h ��) if($subtopic_mode);
		$submit = "���̓��e��$mark���M����";
		$line .= qq(<input type="hidden" name="res" value="$finput_res">\n);
		$line .= qq(<input type="hidden" name="res" value="$finput_res">\n);
	}

	# ���e�{�^��
	if($my_use_device->{'smart_flag'}){
		$submit = qq(���M����);
		$preview_button_title = qq(�v���r���[);
	} else {
		$submit = qq(���̓��e�ő��M����);
		$preview_button_title = qq(���̓��e�Ńv���r���[����);
	}

$line .= qq(<table summary="���e�t�H�[��" class="table1">$alert_text);

	# �e���v���G���A
	if(Mebius::Admin::admin_mode_judge()){
		my $admin_template = main::get_calltemplate();
		$line .= qq(
		<tr><td class="no2">����</td>
		<td class="template">
		<a href="javascript:vswitch('resform_auto_text_for_admin');" class="fold">���e���v���[�g��\\��</a>
		<div id="resform_auto_text_for_admin" class="none">
		$admin_template
		</div></td></tr>
		);

	}

	# �V�K���e���̑薼���̓t�H�[��
	if($use->{'NewMode'}){
		$submit = "���̓��e�ő��M����";
		$line .= qq(<tr><td class="no2 valign-top"><label for="subject">�薼</label></td><td class="no"><input type="text" name="sub" class="input" size="10" value="$in{'sub'}" maxlength="50" id="subject"></td></tr>);
	}

# maxlength ���`
my $maxlength_name = qq( maxlength="60");

# ���e�������擾
my($myhistory) = Mebius::my_history();

	foreach(split(/\s/,$myhistory->{'names'})){
		$i_names++;
		if($i_names > 5){ last; }
		my($name_decoded2) = Mebius::Decode(undef,$_);
		if($name_decoded2 eq $finput_name){ next; }
		else{
			$other_name_inputs .= qq(<input type="radio" name="other_name" value="$name_decoded2" id="other_name_$i_names" onclick="vdisabled('resform_handle');">);
			$other_name_inputs .= qq(<label for="other_name_$i_names">$name_decoded2</label>\n);
		}
	}

	# Javascript��`
	if($other_name_inputs){
		$main::javascript_text .= qq(
		function clear_checked(){
			for(i=0;i<document.RESFORM.other_name.length;i++){
				document.RESFORM.other_name[i].checked=false;
			}
			document.RESFORM.other_name.checked=false;
		}
		);
	}

# ���M�����̓t�H�[��
$line .= qq(<tr><td class="no2 valign-top"><label for="resform_handle">);
	if($my_use_device->{'smart_flag'}){
	} else {
		$line .= qq(�M��);
	}
$line .= qq(</label></td><td class="no">\n);

	# �M�����i
	if(Mebius::Admin::admin_mode_judge()){
		$line .= qq(<input type="text" size="10" class="input" value="$my_admin->{'name'}" disabled>\n);
	} else {
		$line .= qq(<input type="text" name="name" size="10" class="input" value="$finput_name" accesskey="1" title="Alt+1" id="resform_handle" placeholder="�n���h���l�[��">\n);
	}

	# �����̕M��������ꍇ ( 1 )
	if($other_name_inputs && !Mebius::Admin::admin_mode_judge()){
		# �\������
		$line .= qq(<span id="other_handle">);
		$line .= qq( <a href="javascript:vblock('other_handle_hidden');vinline('fold_202');vnone('other_handle');" class="fold size90">��</a> );
		$line .= qq(</span>\n);
		# �B������
		$line .= qq(<span class="display-none" id="fold_202">);
		$line .= qq( <a href="javascript:clear_checked();vnone('other_handle_hidden');vnone('fold_202');vinline('other_handle');venable('resform_handle');" class="fold size90">��</a> );
		$line .= qq(</span>\n);
	}

# �����F���̓t�H�[��
	# �f�X�N�g�b�v��
	if(!$my_use_device->{'smart_flag'}){
		$line .= qq(<label for="color">�F</label>);
	}

my(@color) = Mebius::Init::Color();
$line .= qq(<select name="color" accesskey="9" id="color">);
	foreach(@color) {
		my($col_name, $col_code) = split(/=/);
			if($col_code eq $finput_color) {
				$line .= qq(<option value="$col_code" style="color:$col_code;"$main::parts{'selected'}>$col_name$main::parts{'option_close'}\n);
			}
			else { $line .= qq(<option value="$col_code" style="color:$col_code;">$col_name$main::parts{'option_close'}\n); }
	}

	$line .= qq(</select>);
	#$line .= qq( <span class="guide" style="font-size:80%;" title="�����F���ĕҐ����܂����B�B�z�F���ς���Ă���ꍇ�́A���萔�ł����A�F��I�ђ����Ă��������B">���ꕔ�ĕ�</span>);

	# �X�^���v���̓G���A
	if(Mebius::Stamp::allow_use_stamp_judge()){
		$line .= qq(�@);
			if($use->{'Preview'} && Mebius::Stamp::use_stamp_judge("comment")){
				$line .= Mebius::Stamp::form({ FromEncoding => "sjis" , DefaultOpen => 1 }) ;
			} else {
				$line .= Mebius::Stamp::form({ FromEncoding => "sjis" }) ;
			}
	}

	#if($cookie && !$my_use_device->{'smart_flag'}){
		#$line .= qq(�@<a href="/_main/?mode=my&amp;bbs=$moto&amp;back=$in{'no'}" target="_blank" class="blank">���}�C�y�[�W</a>);
	#}



	# �߂��
	my $backurl_paint;
	if($use->{'NewMode'}){ $backurl_paint = Mebius::Encode("","http://$main::server_domain/_$main::realmoto/?mode=form&type=image") . Mebius::Encode("","#RESFORM"); ; }
	else{ $backurl_paint = $main::selfurl_enc . Mebius::Encode("","#RESFORM"); }




	if($cookie && $my_real_device->{'type'} eq "Desktop" && !$use->{'EditMode'}){
		# && !$main::k_access
		$line .= qq(�@<a href="/_main/?mode=pallet&amp;backurl=$backurl_paint" target="_blank" class="blank">�����G����</a>);
	}

	# ���L���ւ̃����N
	if($use->{'ResMode'} && $use->{'Preview'}){
		$line .= qq(�@<a href="$in{'res'}.html" target="_blank" class="blank">�����L����</a>);
	}


	# ���u���̕M���v������ꍇ ( 3 )
	if($other_name_inputs){
		$line .= qq(<div class="display-none" id="other_handle_hidden">);
		$line .= qq($other_name_inputs\n);
		$line .= qq(</div>\n);
	}

	# �҂����Ԃ���ꍇ�A�e�L�X�g�ǉ�
	if($use->{'GetMode'}){ $textarea .= $wait_textarea; }

# �e�L�X�g�G���A�p�̋Ǐ���
my($placeholder_textarea,$guide_text_textarea,$guide_text_submit_button);

	# �e�L�X�g�G���A�� placeholder
	if($my_use_device->{'smart_flag'}){
		$placeholder_textarea = qq( placeholder="�{��");
	}
	else{
		$guide_text_textarea = qq(�{��);
		#$guide_text_submit_button = qq(���e);
	}

	# �X�^���v���̓G���A
	if(Mebius::Stamp::allow_use_stamp_judge()){
		my($parts);
			if($use->{'Preview'} && Mebius::Stamp::use_stamp_judge("comment")){
				($textarea) .= Mebius::Stamp::stamp_list_area({ NaturalParts => 1 , FromEncoding => "sjis" });
			} else { 
				($textarea) .= Mebius::Stamp::stamp_list_area({ FromEncoding => "sjis" });
			}
	}

	# �`���b�g���[�h�̃e�L�X�g�G���A
	if($init_bbs->{'concept'} =~ /Chat-mode/ && $use->{'ResMode'}){
		$textarea .= qq(<input type="text" name="comment" value="$textarea_input" class="chat_input" size="10" maxlength="80" accesskey="2" id="comment"$placeholder_textarea>);
	# ���ʂ̃e�L�X�g�G���A
	} else {
			if($textarea_input && $query->param('report_url')){

				my($justy_from_url) = Mebius::justy_url_check($query->param('report_url'));
				my($justy_from_url_escaped) = e($justy_from_url);
					if($justy_from_url){ $textarea_input =~ s/\[REFERER\]/$justy_from_url_escaped/g; } else { $textarea_input =~ s/\[REFERER\]//g; }
			} else { $textarea_input =~ s/\[REFERER\]//g; }

		$textarea .= qq(<textarea cols="25" rows="5" name="comment" accesskey="2" title="Alt+2" class="wide" id="comment"$placeholder_textarea>$textarea_input</textarea>);
	}

	# ���\���A�\�͕\���̃`�F�b�N
	if($use->{'NewMode'}){ require "${init_directory}part_sexvio.pl"; &sexvio_form(); }

	# �Ǘ��p [ ���O�ɒǉ� ] �̕���
	if(Mebius::Admin::admin_mode_judge()){
		my $html = Mebius::HTML->new();
		$line .= qq([ ���O�ɒǉ� );
		$line .= $html->radio("nameplus","","�Ȃ�");
		$line .= $html->radio("nameplus","�Ή���","�Ή���");
		$line .= $html->radio("nameplus","�A���̂�","�A���̂�");
		$line .= qq( ] );
	}

# ���̓t�H�[��
$line .= qq(
</td></tr>
<tr><td class="no2 valign-top"><label for="comment">$guide_text_textarea</label></td>
<td class="no">$textarea$viocheck$sexcheck</td></tr>);

	# ���������摜�̓Y�t�G���A
	if(!$use->{'EditMode'}){
		$line .= resform_pallet($use,$use_thread);
	}

	# �摜�A�b�v���[�h�t�H�[��
	if(!$use->{'EditMode'}){
		$line .= qq($input_upload);
	}

$line .= qq($under_alert
<tr><td class="no2 valign-top">$guide_text_submit_button</td>
<td class="no">
<input type="submit" name="preview" value="$preview_button_title" class="ipreview" accesskey="3" title="Alt+3">
 <input type="submit" value="$submit" class="isubmit" class="isubmit">
);

	# �L���A�b�v�̃`�F�b�N�𔻒�
	# �X�}�t�H�U�蕪��
	if($my_use_device->{'smart_flag'}){
		$line .= qq(<br$main::xclose><br$main::xclose>);
	}
	else{
		$line .= qq(�@);
	}

	# ���e��`�F�b�N�{�b�N�X
	if(!$use->{'EditMode'}){

		my $form_parts = new Mebius::BBS::Form;

			if($use->{'ResMode'}){
				# �A�J�E���g�ւ̃����N
				($line) .= $form_parts->thread_up({ from_encoding => "sjis" });
			}	else {
				# �A�J�E���g�ւ̃����N
				($line) .= $form_parts->thread_up({ Hidden => 1 , from_encoding => "sjis" });
			}

			# �A�J�E���g�ւ̃����N
			($line) .= $form_parts->account_link({ from_encoding => "sjis" });
			#($line) .= $form_parts->history({ from_encoding => "sjis" });

			($line) .= $form_parts->news({ from_encoding => "sjis" });

			my $debug = new Mebius::Debug;
			$line .= shift_jis($debug->escape_error_checkbox());
	}


$line .= qq(</td></tr>);

	# ���E���G���A
	if(!$use->{'EditMode'}){

		# ���`
		$line .= qq(<tr><td class="no2"></td>\n);
		$line .= qq(<td class="no right line-height">\n);

		# ���m�点���[��
		my($email_value,$onclick,$checked_email_tell);
			if($main::in{'email'}){ $email_value = $main::in{'email'}; }
			elsif($main::cemail){ $email_value = $main::cemail; }
			#if($email_value eq ""){ $email_value = 'example@ne.jp'; $onclick = qq( onclick="javascript:this.value=''"); }
			if($main::in{'email_tell'} eq "tell"){ $checked_email_tell = $parts->{'checked'}; }
		$line .= qq(<br$main::xclose>\n);
		$line .= qq(<div class="inline" style="font-size:90%;color:#222;">\n);
		$line .= qq(<label><input type="checkbox" name="email_tell" value="tell" id="email_tell"$checked_email_tell><span> ���̋L���Ƀ��X����������A���̃��[���A�h���X�܂ł��m�点����</span></label> );
		$line .= qq(<input type="email" name="email" value="$email_value" id="email_resform" placeholder="��\) example\@ne.jp"> );
		$line .= qq(</div>\n);

		# ���`
		$line .= qq(</td>\n);
		$line .= qq(</tr>\n);

	}

# ���e�t�H�[���I���
$line .= qq(</table></div>);

	# �X�}�t�H��
	if($my_use_device->{'smart_flag'}){
		$line .= qq(<hr>);
	}

	# �t�H�[�����i�I���
	if(!$use->{'NotSetFormTag'}){
		$line .= qq(</form>\n);
	}


# ���^�[��
return($line);

}


#-----------------------------------------------------------
# ���������p���b�g�ւ̃����N
#-----------------------------------------------------------
sub resform_pallet{

# �錾
my($type) = shift if(ref $_[0] eq "");
my($use) = shift if(ref $_[0] eq "HASH");
my $use_thread = shift;
my($line,$image_id,%image,$image_session,$backurl_paint,$image_e_flag,$select_line,$checked_flag,$checked_none);
my($init_directory) = Mebius::BaseInitDirectory();
my($my_use_device) = Mebius::my_use_device();
my($my_real_device) = Mebius::my_real_device();
our($concept,%in,$paint_url,$realmoto,$paint_dir,$main_url,$cookie,$postflag,$css_text);

	# ���^�[������ꍇ
	if($use_thread->{'concept'} =~ /Not-use-paint/){ return(); }
	if(!$ENV{'HTTP_COOKIE'}){ return(); }

# CSS��`
$css_text .= qq(
div.paint_select{margin:0.5em 0em;padding:0.5em 1.0em;background:#eef;line-height:1.6em;border:solid 1px #55f;font-size:90%;}
);

	# �߂��
	if($type =~ /NEW/ || $use->{'NewMode'}){ $backurl_paint = Mebius::Encode("","http://$main::server_domain/_$main::realmoto/?mode=form&type=image") . Mebius::Encode("","#RESFORM"); ; }
	else{ $backurl_paint = $main::selfurl_enc . Mebius::Encode("","#RESFORM"); }

	my($cookie) = Mebius::get_cookie("Paint");
	my($cookie_concept,$cookie_session) = @$cookie;

	# �N�b�L�[�̔z���W�J
	foreach(split(/\s/,$cookie_session)){

		# �Z�b�V����������A�b�v�\��摜�̊e��f�[�^���擾
		my(%image) = Mebius::Paint::Image("Get-hash Post-check",$_);

			# �L���ȉ摜�Ȃ�\������
			if($image{'post_ok'}){
				my($checked);
				if($type =~ /PREVIEW/ && $in{'image_session'} eq $image{'session'}){ $checked = $main::parts{'checked'}; $checked_flag = 1; } # �v���r���[�̏ꍇ
				elsif(!$checked_flag && time <= $image{'lasttime'} + 3*60){ $checked = $main::parts{'checked'}; $checked_flag = 1; }	# �������ꎞ�ۑ������G�̏ꍇ
				$select_line .= qq( <label for="paint_$image{'session'}">);
				$select_line .= qq(	<input type="radio" name="image_session" value="$image{'session'}" id="paint_$image{'session'}"$checked>);
				$select_line .= qq(	<a href="$image{'image_url_buffer'}" target="_blank" class="blank">$image{'title'}</a> );
				$select_line .= qq( </label>);
				$image_e_flag = 1;
			}
	}

	# ���`
	if(!$checked_flag){ $checked_none = $main::parts{'checked'}; }
	if($select_line){ $select_line = qq(<input type="radio" name="image_session" value="" id="paint-none"$checked_none> <label for="paint-none">�Y�t���Ȃ�</label> $select_line); }
	$line .= $select_line;

	# ��������`��
	if($image_e_flag){	
		$line .= qq(�@[ <a href="${main_url}?mode=pallet&amp;continue=1&amp;backurl=$backurl_paint" target="_blank" class="blank">�����G��������</a> ]);
	}

	# ���݂��}�C�i�X�̏ꍇ
	#if($main::cgold < 0 && !Mebius::alocal_judge()){ $line = qq( ���݂��}�C�i�X�̂��߁A���G�����@�\\�͎g���܂���B); }

	if($line eq ""){
			#if($my_real_device->{'type'} ne "Desktop"){ return(); }
			#else{ $line = qq( ���݁A�Y�t�ł���G�͂���܂���B [ <a href="/_main/?mode=pallet&amp;backurl=$backurl_paint" target="_blank" class="blank">�����G��������</a> ]); }
	}

	# ���G�����]�[��
	if($line){
		$line = qq(<tr><td class="no2">�G</td><td class="no"><div class="paint_select">$line</div></td></tr>);
	}


return($line);


}

#-----------------------------------------------------------
# ���ӕ�
#-----------------------------------------------------------
sub bbs_threadform_alert{

my($type) = @_ if(ref $_[0] eq "");
my($use) = @_ if(ref $_[0] eq "HASH");
my(undef,$main_thread,$sub_thread) = @_;
my($alert_text,$under_alert);
my $d_delman = $main_thread->{'delete_data'};
my($my_use_device) = Mebius::my_use_device();
my($init_directory) = Mebius::BaseInitDirectory();
my($basic_init) = Mebius::basic_init();
my $bbs_path = Mebius::BBS::Path->new($main_thread);
my $sub_thread_url = $bbs_path->thread_url_adjusted({ SubThread =>1 });
our(%in,$head_title,$moto,$category,$sub_nofollow,$subtopic_mode,$subtopic_link);

	# �T�u�L��
	if($type =~ /RES/ || $use->{'ResMode'}){
			if($subtopic_link && !$subtopic_mode && $sub_thread->{'key'} ne "0"){
		my $text = qq(���c���z�E�R�����g�͂��̋L���ł͂Ȃ��A<a href="$sub_thread_url" target="_blank" class="blank"$sub_nofollow>�T�u�L��</a>�ɏ�������ł��������B);
			if($category eq "novel"){ $text .= qq(�i�����J�e�S���ł͕K�{�ł��j); }
			if($category eq "narikiri"){ $text = qq(���c�i�s���k�E�ݒ��<a href="/_sub$moto/$in{'no'}.html" target="_blank" class="blank"$sub_nofollow>�T�u�L��</a>�������p���������i�e�X�g���j�B); }
				$under_alert .= qq(<tr><td class="no"></td><td class="alert2"><strong class="alert">$text</strong></td></tr>);
			}
	}

# �x��
$alert_text .= qq(<tr><td colspan="2" class="no ip_alert">\n);

#�������ނƁA���Ȃ��̐ڑ��f�[�^ \( ) . Escape::HTML([$ENV{'REMOTE_ADDR'}]) . qq( \�j �������ɕۑ�����܂��B

# ���e��̒��� ( �{�� )
my 	$alert_text_body = qq(<span class="ip_alert alert">���K�� <a href="rule.html" target="_blank" class="blank">���[�J�����[��</a> �� <a href="$basic_init->{'guide_url'}%A5%E1%A5%D3%A5%A6%A5%B9%A5%EA%A5%F3%A5%B0%B6%D8%C2%A7" target="_blank" class="blank">���r�E�X�����O�̃��[��</a> ���������������B</span>);

	# �X�}�t�H��
	if($my_use_device->{'smart_flag'}){
		$alert_text .= qq(<div id="ip_alert_natural" class="ip_alert">);
		$alert_text .= qq(<a href="javascript:vinline('ip_alert_hidden');vnone('ip_alert_natural');" class="red fold">�����e��̂�����</a>);
		$alert_text .= qq(</div>);
		$alert_text .= qq(<div id="ip_alert_hidden" class="display-none">);
		$alert_text .= qq($alert_text_body);
		$alert_text .= qq( <a href="javascript:vinline('ip_alert_natural');vnone('ip_alert_hidden');" class="fold">�~����</a> );
		$alert_text .= qq(</div>);
	}
	# �f�X�N�g�b�v��
	else{
		$alert_text .= qq($alert_text_body);
	}

	# �L�����Ƃ̌x���i�Ǘ��Ґݒ�j
	if($main_thread->{'concept'} =~ /Alert-violation/){

		# �폜���𕪉�
		my(undef,undef,$lasttime,$reason) = split(/=/,$d_delman);
		require "${init_directory}part_delreason.pl";
		my($reason_text,$reason_subject,$reason_comment,$operation) = &delreason($reason,undef,$main_thread->{'sub'},$head_title);
			# �Ǘ��Ґݒ肩��P�T�Ԉȓ��̏ꍇ
			if($lasttime + 30*24*60*60 >= time && $reason){
				$alert_text .= qq(<br$main::xclose><br$main::xclose>);
				$alert_text .= qq(<div class="thread_alert1">�Ǘ��҂���̃��b�Z�[�W�i�d�v�j�@ - $reason_subject -</div>);
				$alert_text .= qq(<div class="thread_alert2">);
				#$alert_text .= qq(<span class="red">�y$reason_subject�z</span><br$main::xclose>);
				$alert_text .= qq($reason_comment);
				$alert_text .= qq(<br$main::xclose>�s�K�؂ȏ�Ԃ������ꍇ�A�L�������b�N/�폜�����Ă��������ꍇ������܂��B);
					if($operation){ $alert_text .= qq(<br$main::xclose>�@<span class="red">���΍�F $operation </span>); }
				$alert_text .= qq(</div>);
				$main::css_text .= qq(div.thread_alert1{font-size:90%;background:#f22;color:#fff;font-weight:bold;padding:0.5em 1.0em;});
				$main::css_text .= qq(div.thread_alert2{font-size:90%;padding:0.5em 1.0em;line-height:1.8em;border:solid 1px #f00;});
			}
	}

$alert_text .= qq(</td></tr>);

return($alert_text,$under_alert);

}

package main;
no strict;

#-----------------------------------------------------------
# �f�X�N�g�b�v�� �v���r���[�ƃG���[
#-----------------------------------------------------------
sub regist_rerror{

# �錾
my($regist_type);
our($echeck_flag,$css_text);
my($init_directory) = Mebius::BaseInitDirectory();
my($my_use_device) = Mebius::my_use_device();
my($init_bbs) = Mebius::BBS::init_bbs_parmanent_auto();
my($param) = Mebius::query_single_param();
my($thread_view_line);

# �G���[���A�����b�N
if($lockflag) { &unlock($lockflag); }


	# �X�}�t�H��
	if($my_use_device->{'smart_flag'}){
		$main::css_text .= qq(.body1{width:100%;}\n);
	}

# �e�\���G���A���Z�b�g
my($fasterror_line) = rerror_set_fasterror(@_);
my($preview_line,$index_preview_line) = preview_area_resform($use);
my($error_line) = rerror_set_error($e_com);
my($data_line) = rerror_set_data();

	# �摜�Y�t�G���A
	if($init_bbs->{'concept'} =~ /Upload-mode/){ upload_setup(); }

	# ���ӕ�
	if(!$e_com && !$_[0]){
		$please_line = qq(	<strong class="mada">	���܂��������܂�Ă��܂���B <input type="submit" value="���̓��e�ő��M����"> ���������A�ҏW�t�H�[���œ��e��ύX���Ă��������B</strong><br><br>);
	}

# �^�C�g����`
$sub_title = qq(���e | $title);

	# �ҏW�t�H�[����\��
my($new_mode,$res_mode);
	if($in{'res'}){ $res_mode = 1; }
	else{ $new_mode = 1; }
	require "${init_directory}part_resform.pl";
	my($resform_line) = bbs_thread_form({ Preview => 1 , NewMode => $new_mode , ResMode => $res_mode , NotSetFormTag => 1 });

	# ���̃X���b�h��\�� ( ���X���e���̂� )
	if($param->{'no'} ne ""){
		require "${init_directory}part_view.pl";
		($thread_view_line) = main::bbs_view_thread({ Preview => 1 });
	}


my $print .= $thread_view_line;

# �t�H�[���n�܂�
$print .= qq(
<form action="$script?regist#RESFORM" method="post" name="RESFORM" id="RESFORM"$formtype$sikibetu>
<div class="thread_body bbs_border">
<div class="d">
$fasterror_line
$please_line
$error_line
$data_line
$preview_line
$alert_line
</div></div>
$index_preview_line
);

# �i�r�Q�[�V���������N
# �i�r�Q�[�V���������N
my($navi_links2) = shift_jis(Mebius::BBS::thread_navigation_links({ bbs_kind => $main::moto , thread_number => $main::in{'res'} },{ Bottom => 1 }));

$print .= $navi_links2;

# �y�[�W�I���
$print .= qq($resform_line);
$print .= qq(</form>);

# �t�b�^
	# �t�b�^
	if($my_use_device->{'smart_flag'} || Mebius::alocal_judge()){
		Mebius::Template::gzip_and_print_all({ Jquery => 1 , javascript_files => ['jquery.flicksimple'] },$print);
	} else {
		Mebius::Template::gzip_and_print_all({},$print);
	}

exit;

}

#-----------------------------------------------------------
# �����G���[
#-----------------------------------------------------------
sub rerror_set_fasterror{

# �Ǐ���
my($line);

# ���^�[��
if($_[0] eq ""){ return; }

# �\�����e
$line = qq(
<div class="special_error">
<strong class="red">����G���[�F</strong><br>
��$_[0]<br>
�����b�Z�[�W�ɏ]���Ă��󋵂����P����Ȃ��ꍇ�́A${mailform}���炲�A�����������܂��B<br>
�@�u�G���[���N�����ꏊ�v�u�L���̂t�q�k�v�u���m�ȃG���[���b�Z�[�W�v�ȂǏڂ����������`�����������B<br>
</div><br>
);

return($line);

}


#--------------------------------------------------------------
# ���e�G���[
#--------------------------------------------------------------
sub rerror_set_error{

# �Ǐ���
my $error = shift;
my($line,$error_text,$pleasechange_text);

	# ���^�[��
	if(!$error){ return; }

# �G���[���e
$error_text = "$error";

# �G���[�\��
$line = qq(
<div class="error_line">
<span class="red">�G���[�F </span><br>
$error_text
$pleasechange_text
</div>
<br>
);

return($line);

}

#--------------------------------------------------------------
# �\���f�[�^
#--------------------------------------------------------------
sub rerror_set_data{

# �Ǐ���
my($up,$line,$pre_sub,$rer_option,$news_option,$next_charge);
my($my_account) = Mebius::my_account();
our($nextcharge_minsec,$cgold,$pmfile,%in);

	# ���^�[��
	if($_[0] || $strong_emd){ return; }

	# �V�K���e�ł���΁i���e�f�[�^���e�ɒǉ��j
	if($in{'res'} eq ""){ $pre_sub = " &gt; <strong>�V�����L��</strong>"; }

	# ���X���e�̏ꍇ�A�������f�[�^��\��
	if($in{'res'} ne ""){
		$next_charge .= qq(�@<strong>��</strong>�@����`���[�W�� $nextcharge_minsec �ł�$text);
			if($norank_wait){ $next_charge .= qq( (�ꗥ)); }
			elsif($cgold >= 1){ $next_charge .= qq(�@( ���݂̉e���ŗL���� )); }
			elsif($cgold <= -1){ $next_charge .= qq(�@( ���݂̉e���ŕs���� )); }
	}

	# �A�b�v���邩���Ȃ���
	if($in{'res'} ne ""){
			if($in{'up'} eq "1"){ $rer_option = qq(�@�I�v�V�����F �L����<strong class="red">�A�b�v</strong>); }
			else{ $rer_option = qq(�@�I�v�V�����F �Ȃ�);}
	}


	# �g�b�v�f��
	#if($in{'news'}){ $news_option = qq( / �g�b�v�f�ڂ���); }
	#else{ $news_option = qq( / �g�b�v�f�ڂ��Ȃ�); }


# ���e�f�[�^���e ���`
$line = qq(<div class="data_line">);
$line .= qq(<strong class="middle">$smlength����</strong> �𓊍e);


#if($cgold ne ""){ $line .= qq( ( +<img src="/pct/icon/gold1.gif" alt="����" title="����"> ��$cgold�� ) ); }
$line .= qq($next_charge);
#$line .= qq(<br$main::xclose>���e��F <a href="./">$title</a> $pre_sub $rer_option $news_option);
$line .= qq(</div><br>);

return($line);

}

#use strict;

#--------------------------------------------------------------
# �v���r���[
#--------------------------------------------------------------
sub preview_area_resform{

# �Ǐ���
my $use = shift;
my($line,$index_preview_line,$pre_res,$name,$id,$trip,$preview_title);
my(%image,$image_preview);
my $query = new CGI;
our($new_res_concept);
my($basic_init) = Mebius::basic_init();
my($my_account) = Mebius::my_account();
my($now_date) = Mebius::now_date();

# ���`
$trip = qq(���g���b�v) if $enctrip;

	my($id_history_judge) = Mebius::BBS::id_history_level_judge({ from_encoding => "sjis" });
	if($id_history_judge->{'record_flag'}){
		$id = qq(<i><a href="./" class="idory" target="_blank" class="blank">��).e($encid).qq(</a></i>);
	}
	else{
		$id = qq(<i>��).e($encid).qq(</i>);
	}

$pre_res = $query->param('pre_res') + 1;
$name = "$i_handle$trip";
	if($my_account->{'login_flag'} && $query->param('account_link')){ $name = qq(<a href="$basic_init->{'auth_url'}$my_account->{'id'}/" target="_blank" class="blank">$name</a>);} 

# ���̓G�t�F�N�g
($i_com) = Mebius::Effect::all($i_com);

# �I�[�g�����N
($i_com) = &bbs_regist_auto_link($i_com);

# ���Xj�R���Z�v�g�ł̐��`
my($comment_style) = Mebius::BBS::CommentStyle(undef,$new_res_concept);

# �v���r���[�錾
$preview_title = qq(<div class="preview_line">�v���r���[</div><br>);

	# ���������摜
	if($in{'image_session'}){
		(%image) = Mebius::Paint::Image("Get-hash Post-check",$in{'image_session'});
			if($image{'post_ok'}){
				$image_preview .= qq(<div class="paint_image">);
				$image_preview .= qq(<a href=").e($image{'image_url_buffer'}).qq(">);
				$image_preview .= qq(<img src=").e($image{'samnale_url_buffer'}).qq(" alt="�Y�t�摜">);
				$image_preview .= qq(</a>);
				$image_preview .= qq(</div>);
			}

	}

	# �V�K���e�̏ꍇ
	if ($use->{'NewMode'}){
		my $color = $query->param('color');
		$color =~ s/[^\#0-9a-f]//g;
		$line .= qq(
		$preview_title
		<b style="color:$color;">).e($i_sub).qq(</b><br><br>
		<div style="color:$color;">
		<b>$name</b> $id
		<br><br><span$comment_style>$i_com</span><br>$image_preview<div class="date">).e($now_date).qq( No.0</div></div><br>
		);
	}

	# ���X���e�̏ꍇ
	else{
		my $color = $query->param('color');
		$color =~ s/[^\#0-9a-f]//g;

		$line .= qq(
		$preview_title

		<div style="color:$color;">
		<b>$name</b> $id<br><br><span$comment_style>$i_com</span><br>$image_preview
		<div class="date">$now_date No.$pre_res</div></div><br>
		);
	}


	# INDEX �v���r���[
	if($use->{'NewMode'}){
		$index_preview_line = qq(
		<table cellpadding="3" summary="�L���ꗗ" class="table2 bbs">
		<tr><th class="td0">��</th><th class="td1">�薼</th><th class="td2">���O</th><th class="td3">�ŏI</th><th class="td4"><a name="go"></a>�ԐM</th></tr>
		<tr><td><a href="./">��</a></td><td><a href="./">).e($i_sub).qq(</a></td><td>).e($i_handle).qq(</td><td>).e($i_handle).qq(</td><td>0��</td></tr>
		</table>
		);
	}



return($line,$index_preview_line);

}

1;


1;

