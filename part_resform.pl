
use strict;
use Mebius::Paint;
use Mebius::BBS;
use Mebius::History;
use Mebius::Text;

package main;
use Mebius::Export;

#-----------------------------------------------------------
# 掲示板の投稿フォーム
#-----------------------------------------------------------
sub bbs_thread_form{

# 宣言
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

# CSS定義
$css_text .= qq(
td.alert,td.alert2{font-size:90%;border-style:none;color:#f00;padding:0em 0em 0.5em 0em;}
td.alert2{font-size:120%;}
.ip_alert{font-size:90%;padding:0.3em;color:#f00;}
td.ip_alert{padding-bottom:0.5em;}
div.resform{margin:0em;}
.no2{text-align:center;}
);

	if($use->{'Preview'}){

		# CSS定義
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

		# CSS定義 ( 他の処理との共通部分 )
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

	# 初期入力チェック ( プレビューの場合 )
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
	# 初期入力チェック ( その他の場合 )
			if(!Mebius::Admin::admin_mode_judge()){
				$textarea_input = $init_bbs->{'textarea_first_input'};
			}
		$finput_color = $my_cookie->{'font_color'};
		$finput_name = $my_cookie->{'name'};
		$finput_res = $in{'no'};
		$finput_pre_res = $res;
		$finput_access_time = time;
	}


# 汚染チェック
$finput_res =~ s/\D//g;

# 入力整形
$textarea_input =~ s/<br$xclose>/\n/g;
$finput_sub = $in{'sub'};

	# 下部メニューリンクを定義
	if($use->{'GetMode'}){
		my($plus_type);
		my $move_side_links_flag = 1 if($main::mode eq "view" && !$main::subtopic_mode);
		($navi_links2) = shift_jis(Mebius::BBS::thread_navigation_links($use_thread,{ Bottom => 1 , MoveSideLinks => $move_side_links_flag }));
	}

	# 時間帯で投稿禁止
	#if($type =~ /RES/){ ($line) .= &thread_deny_hour(); }

	# フォーム帯
	if($use->{'GetMode'} && $use->{'ResMode'}){

		# ストップモード
		if(Mebius::Switch::stop_bbs()){
			$line .= qq(<div class="thread_status"><a href="$basic_init->{'guide_url'}" class="white">この掲示板は投稿停止中です。</a></div>\n);
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
		elsif($key eq '7') { $line .= qq(<div class="thread_status"><a href="$basic_init->{'guide_url'}" class="white">この記事は$titleのメニューから削除済みです。</a></div>\n); $return = 1; }
		elsif($key == 3){ $line .= qq(<div class="thread_status">この記事は<a href="./" class="white">$title</a>の<a href="past.html" class="white">過去ログ</a>です</div>); $return = 1; }
		elsif($key == 2){ $line .= qq(<div class="thread_status">管理者からのお知らせです。</div>); $return = 1; }
		elsif($m_max <= $res){ $line .= qq(<div class="thread_status">レスが$m_max件を超えました。</div>\n); $return = 1; }
		elsif($res > ($m_max * 0.9)){
			$line .= qq(<div class="thread_status">レスが$res件あります。$m_max件を越えると記事が終了します。\n);
			$line .= qq(</div>);
		}
		elsif($subtopic_mode && $sub_thread->{'key'} eq "0"){ $line .= qq(<div class="thread_status">このサブ記事には書き込めません。</div>); $return = 1; }
		elsif($concept =~ /Not-regist/){ $line .= qq(<div class="thread_status">この掲示板は投稿停止中です。</div>); $return = 1; }
		elsif($stop_regist_mode){ $line .= qq(<div class="thread_status">現在、投稿を受け付けていません。</div>); $return = 1; }
		elsif($key == 4){ $return = 1; }

	}

	# 投稿フォームを表示しない場合
	if($use->{'GetMode'}){
			if($use->{'ResMode'}){ $line .= qq($navi_links2); }
			if($use->{'ResMode'} && !$return){ $line .= qq(); }
			if($return){ $line .= qq(</div>); return($line); }
	}

# 投稿時の注意
my($alert_text,$under_alert) = bbs_threadform_alert($_[0],$main_thread,$sub_thread);

	# 画像添付エリア
	if($init_bbs->{'concept'} =~ /Upload-mode/){ require "${init_directory}part_upload.pl"; &upload_setup(); }

	# 送信用、現在のレス番
	if($in{'resnum'}){ $next_resnumber = $in{'resnum'}; }
	else{ $next_resnumber = $res + 1; }

	# フォーム部品始まり
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

# フォーム開始
$line .= qq(<div class="thread_form bbs_border">\n);

	# ▼フォームのHidden値
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

	# 投稿ボタン
	if($use->{'ResMode'}) {
		my($mark);
		$mark = qq( ”本編” を) if($subtopic_link);
		$mark = qq( ”コメント” を) if($subtopic_mode);
		$submit = "この内容で$mark送信する";
		$line .= qq(<input type="hidden" name="res" value="$finput_res">\n);
		$line .= qq(<input type="hidden" name="res" value="$finput_res">\n);
	}

	# 投稿ボタン
	if($my_use_device->{'smart_flag'}){
		$submit = qq(送信する);
		$preview_button_title = qq(プレビュー);
	} else {
		$submit = qq(この内容で送信する);
		$preview_button_title = qq(この内容でプレビューする);
	}

$line .= qq(<table summary="投稿フォーム" class="table1">$alert_text);

	# テンプレエリア
	if(Mebius::Admin::admin_mode_judge()){
		my $admin_template = main::get_calltemplate();
		$line .= qq(
		<tr><td class="no2">自動</td>
		<td class="template">
		<a href="javascript:vswitch('resform_auto_text_for_admin');" class="fold">▼テンプレートを表\示</a>
		<div id="resform_auto_text_for_admin" class="none">
		$admin_template
		</div></td></tr>
		);

	}

	# 新規投稿時の題名入力フォーム
	if($use->{'NewMode'}){
		$submit = "この内容で送信する";
		$line .= qq(<tr><td class="no2 valign-top"><label for="subject">題名</label></td><td class="no"><input type="text" name="sub" class="input" size="10" value="$in{'sub'}" maxlength="50" id="subject"></td></tr>);
	}

# maxlength を定義
my $maxlength_name = qq( maxlength="60");

# 投稿履歴を取得
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

	# Javascript定義
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

# ●筆名入力フォーム
$line .= qq(<tr><td class="no2 valign-top"><label for="resform_handle">);
	if($my_use_device->{'smart_flag'}){
	} else {
		$line .= qq(筆名);
	}
$line .= qq(</label></td><td class="no">\n);

	# 筆名部品
	if(Mebius::Admin::admin_mode_judge()){
		$line .= qq(<input type="text" size="10" class="input" value="$my_admin->{'name'}" disabled>\n);
	} else {
		$line .= qq(<input type="text" name="name" size="10" class="input" value="$finput_name" accesskey="1" title="Alt+1" id="resform_handle" placeholder="ハンドルネーム">\n);
	}

	# ▼他の筆名がある場合 ( 1 )
	if($other_name_inputs && !Mebius::Admin::admin_mode_judge()){
		# 表示部分
		$line .= qq(<span id="other_handle">);
		$line .= qq( <a href="javascript:vblock('other_handle_hidden');vinline('fold_202');vnone('other_handle');" class="fold size90">▼</a> );
		$line .= qq(</span>\n);
		# 隠し部分
		$line .= qq(<span class="display-none" id="fold_202">);
		$line .= qq( <a href="javascript:clear_checked();vnone('other_handle_hidden');vnone('fold_202');vinline('other_handle');venable('resform_handle');" class="fold size90">▲</a> );
		$line .= qq(</span>\n);
	}

# 文字色入力フォーム
	# デスクトップ版
	if(!$my_use_device->{'smart_flag'}){
		$line .= qq(<label for="color">色</label>);
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
	#$line .= qq( <span class="guide" style="font-size:80%;" title="文字色を再編成しました。。配色が変わっている場合は、お手数ですが、色を選び直してください。">※一部再編</span>);

	# スタンプ入力エリア
	if(Mebius::Stamp::allow_use_stamp_judge()){
		$line .= qq(　);
			if($use->{'Preview'} && Mebius::Stamp::use_stamp_judge("comment")){
				$line .= Mebius::Stamp::form({ FromEncoding => "sjis" , DefaultOpen => 1 }) ;
			} else {
				$line .= Mebius::Stamp::form({ FromEncoding => "sjis" }) ;
			}
	}

	#if($cookie && !$my_use_device->{'smart_flag'}){
		#$line .= qq(　<a href="/_main/?mode=my&amp;bbs=$moto&amp;back=$in{'no'}" target="_blank" class="blank">＠マイページ</a>);
	#}



	# 戻り先
	my $backurl_paint;
	if($use->{'NewMode'}){ $backurl_paint = Mebius::Encode("","http://$main::server_domain/_$main::realmoto/?mode=form&type=image") . Mebius::Encode("","#RESFORM"); ; }
	else{ $backurl_paint = $main::selfurl_enc . Mebius::Encode("","#RESFORM"); }




	if($cookie && $my_real_device->{'type'} eq "Desktop" && !$use->{'EditMode'}){
		# && !$main::k_access
		$line .= qq(　<a href="/_main/?mode=pallet&amp;backurl=$backurl_paint" target="_blank" class="blank">＠お絵かき</a>);
	}

	# 元記事へのリンク
	if($use->{'ResMode'} && $use->{'Preview'}){
		$line .= qq(　<a href="$in{'res'}.html" target="_blank" class="blank">＠元記事へ</a>);
	}


	# ▼「他の筆名」がある場合 ( 3 )
	if($other_name_inputs){
		$line .= qq(<div class="display-none" id="other_handle_hidden">);
		$line .= qq($other_name_inputs\n);
		$line .= qq(</div>\n);
	}

	# 待ち時間ある場合、テキスト追加
	if($use->{'GetMode'}){ $textarea .= $wait_textarea; }

# テキストエリア用の局所化
my($placeholder_textarea,$guide_text_textarea,$guide_text_submit_button);

	# テキストエリアの placeholder
	if($my_use_device->{'smart_flag'}){
		$placeholder_textarea = qq( placeholder="本文");
	}
	else{
		$guide_text_textarea = qq(本文);
		#$guide_text_submit_button = qq(投稿);
	}

	# スタンプ入力エリア
	if(Mebius::Stamp::allow_use_stamp_judge()){
		my($parts);
			if($use->{'Preview'} && Mebius::Stamp::use_stamp_judge("comment")){
				($textarea) .= Mebius::Stamp::stamp_list_area({ NaturalParts => 1 , FromEncoding => "sjis" });
			} else { 
				($textarea) .= Mebius::Stamp::stamp_list_area({ FromEncoding => "sjis" });
			}
	}

	# チャットモードのテキストエリア
	if($init_bbs->{'concept'} =~ /Chat-mode/ && $use->{'ResMode'}){
		$textarea .= qq(<input type="text" name="comment" value="$textarea_input" class="chat_input" size="10" maxlength="80" accesskey="2" id="comment"$placeholder_textarea>);
	# 普通のテキストエリア
	} else {
			if($textarea_input && $query->param('report_url')){

				my($justy_from_url) = Mebius::justy_url_check($query->param('report_url'));
				my($justy_from_url_escaped) = e($justy_from_url);
					if($justy_from_url){ $textarea_input =~ s/\[REFERER\]/$justy_from_url_escaped/g; } else { $textarea_input =~ s/\[REFERER\]//g; }
			} else { $textarea_input =~ s/\[REFERER\]//g; }

		$textarea .= qq(<textarea cols="25" rows="5" name="comment" accesskey="2" title="Alt+2" class="wide" id="comment"$placeholder_textarea>$textarea_input</textarea>);
	}

	# 性表現、暴力表現のチェック
	if($use->{'NewMode'}){ require "${init_directory}part_sexvio.pl"; &sexvio_form(); }

	# 管理用 [ 名前に追加 ] の部分
	if(Mebius::Admin::admin_mode_judge()){
		my $html = Mebius::HTML->new();
		$line .= qq([ 名前に追加 );
		$line .= $html->radio("nameplus","","なし");
		$line .= $html->radio("nameplus","対応中","対応中");
		$line .= $html->radio("nameplus","連絡のみ","連絡のみ");
		$line .= qq( ] );
	}

# 入力フォーム
$line .= qq(
</td></tr>
<tr><td class="no2 valign-top"><label for="comment">$guide_text_textarea</label></td>
<td class="no">$textarea$viocheck$sexcheck</td></tr>);

	# おえかき画像の添付エリア
	if(!$use->{'EditMode'}){
		$line .= resform_pallet($use,$use_thread);
	}

	# 画像アップロードフォーム
	if(!$use->{'EditMode'}){
		$line .= qq($input_upload);
	}

$line .= qq($under_alert
<tr><td class="no2 valign-top">$guide_text_submit_button</td>
<td class="no">
<input type="submit" name="preview" value="$preview_button_title" class="ipreview" accesskey="3" title="Alt+3">
 <input type="submit" value="$submit" class="isubmit" class="isubmit">
);

	# 記事アップのチェックを判定
	# スマフォ振り分け
	if($my_use_device->{'smart_flag'}){
		$line .= qq(<br$main::xclose><br$main::xclose>);
	}
	else{
		$line .= qq(　);
	}

	# ▼各種チェックボックス
	if(!$use->{'EditMode'}){

		my $form_parts = new Mebius::BBS::Form;

			if($use->{'ResMode'}){
				# アカウントへのリンク
				($line) .= $form_parts->thread_up({ from_encoding => "sjis" });
			}	else {
				# アカウントへのリンク
				($line) .= $form_parts->thread_up({ Hidden => 1 , from_encoding => "sjis" });
			}

			# アカウントへのリンク
			($line) .= $form_parts->account_link({ from_encoding => "sjis" });
			#($line) .= $form_parts->history({ from_encoding => "sjis" });

			($line) .= $form_parts->news({ from_encoding => "sjis" });

			my $debug = new Mebius::Debug;
			$line .= shift_jis($debug->escape_error_checkbox());
	}


$line .= qq(</td></tr>);

	# ●右下エリア
	if(!$use->{'EditMode'}){

		# 整形
		$line .= qq(<tr><td class="no2"></td>\n);
		$line .= qq(<td class="no right line-height">\n);

		# お知らせメール
		my($email_value,$onclick,$checked_email_tell);
			if($main::in{'email'}){ $email_value = $main::in{'email'}; }
			elsif($main::cemail){ $email_value = $main::cemail; }
			#if($email_value eq ""){ $email_value = 'example@ne.jp'; $onclick = qq( onclick="javascript:this.value=''"); }
			if($main::in{'email_tell'} eq "tell"){ $checked_email_tell = $parts->{'checked'}; }
		$line .= qq(<br$main::xclose>\n);
		$line .= qq(<div class="inline" style="font-size:90%;color:#222;">\n);
		$line .= qq(<label><input type="checkbox" name="email_tell" value="tell" id="email_tell"$checked_email_tell><span> この記事にレスがあったら、次のメールアドレスまでお知らせする</span></label> );
		$line .= qq(<input type="email" name="email" value="$email_value" id="email_resform" placeholder="例\) example\@ne.jp"> );
		$line .= qq(</div>\n);

		# 整形
		$line .= qq(</td>\n);
		$line .= qq(</tr>\n);

	}

# 投稿フォーム終わり
$line .= qq(</table></div>);

	# スマフォ版
	if($my_use_device->{'smart_flag'}){
		$line .= qq(<hr>);
	}

	# フォーム部品終わり
	if(!$use->{'NotSetFormTag'}){
		$line .= qq(</form>\n);
	}


# リターン
return($line);

}


#-----------------------------------------------------------
# おえかきパレットへのリンク
#-----------------------------------------------------------
sub resform_pallet{

# 宣言
my($type) = shift if(ref $_[0] eq "");
my($use) = shift if(ref $_[0] eq "HASH");
my $use_thread = shift;
my($line,$image_id,%image,$image_session,$backurl_paint,$image_e_flag,$select_line,$checked_flag,$checked_none);
my($init_directory) = Mebius::BaseInitDirectory();
my($my_use_device) = Mebius::my_use_device();
my($my_real_device) = Mebius::my_real_device();
our($concept,%in,$paint_url,$realmoto,$paint_dir,$main_url,$cookie,$postflag,$css_text);

	# リターンする場合
	if($use_thread->{'concept'} =~ /Not-use-paint/){ return(); }
	if(!$ENV{'HTTP_COOKIE'}){ return(); }

# CSS定義
$css_text .= qq(
div.paint_select{margin:0.5em 0em;padding:0.5em 1.0em;background:#eef;line-height:1.6em;border:solid 1px #55f;font-size:90%;}
);

	# 戻り先
	if($type =~ /NEW/ || $use->{'NewMode'}){ $backurl_paint = Mebius::Encode("","http://$main::server_domain/_$main::realmoto/?mode=form&type=image") . Mebius::Encode("","#RESFORM"); ; }
	else{ $backurl_paint = $main::selfurl_enc . Mebius::Encode("","#RESFORM"); }

	my($cookie) = Mebius::get_cookie("Paint");
	my($cookie_concept,$cookie_session) = @$cookie;

	# クッキーの配列を展開
	foreach(split(/\s/,$cookie_session)){

		# セッション名からアップ予定画像の各種データを取得
		my(%image) = Mebius::Paint::Image("Get-hash Post-check",$_);

			# 有効な画像なら表示する
			if($image{'post_ok'}){
				my($checked);
				if($type =~ /PREVIEW/ && $in{'image_session'} eq $image{'session'}){ $checked = $main::parts{'checked'}; $checked_flag = 1; } # プレビューの場合
				elsif(!$checked_flag && time <= $image{'lasttime'} + 3*60){ $checked = $main::parts{'checked'}; $checked_flag = 1; }	# さっき一時保存した絵の場合
				$select_line .= qq( <label for="paint_$image{'session'}">);
				$select_line .= qq(	<input type="radio" name="image_session" value="$image{'session'}" id="paint_$image{'session'}"$checked>);
				$select_line .= qq(	<a href="$image{'image_url_buffer'}" target="_blank" class="blank">$image{'title'}</a> );
				$select_line .= qq( </label>);
				$image_e_flag = 1;
			}
	}

	# 整形
	if(!$checked_flag){ $checked_none = $main::parts{'checked'}; }
	if($select_line){ $select_line = qq(<input type="radio" name="image_session" value="" id="paint-none"$checked_none> <label for="paint-none">添付しない</label> $select_line); }
	$line .= $select_line;

	# 続きから描く
	if($image_e_flag){	
		$line .= qq(　[ <a href="${main_url}?mode=pallet&amp;continue=1&amp;backurl=$backurl_paint" target="_blank" class="blank">→お絵かきする</a> ]);
	}

	# 金貨がマイナスの場合
	#if($main::cgold < 0 && !Mebius::alocal_judge()){ $line = qq( 金貨がマイナスのため、お絵かき機能\は使えません。); }

	if($line eq ""){
			#if($my_real_device->{'type'} ne "Desktop"){ return(); }
			#else{ $line = qq( 現在、添付できる絵はありません。 [ <a href="/_main/?mode=pallet&amp;backurl=$backurl_paint" target="_blank" class="blank">→お絵かきする</a> ]); }
	}

	# お絵かきゾーン
	if($line){
		$line = qq(<tr><td class="no2">絵</td><td class="no"><div class="paint_select">$line</div></td></tr>);
	}


return($line);


}

#-----------------------------------------------------------
# 注意文
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

	# サブ記事
	if($type =~ /RES/ || $use->{'ResMode'}){
			if($subtopic_link && !$subtopic_mode && $sub_thread->{'key'} ne "0"){
		my $text = qq(注…感想・コメントはこの記事ではなく、<a href="$sub_thread_url" target="_blank" class="blank"$sub_nofollow>サブ記事</a>に書き込んでください。);
			if($category eq "novel"){ $text .= qq(（小説カテゴリでは必須です）); }
			if($category eq "narikiri"){ $text = qq(注…進行相談・設定は<a href="/_sub$moto/$in{'no'}.html" target="_blank" class="blank"$sub_nofollow>サブ記事</a>をご利用ください（テスト中）。); }
				$under_alert .= qq(<tr><td class="no"></td><td class="alert2"><strong class="alert">$text</strong></td></tr>);
			}
	}

# 警告
$alert_text .= qq(<tr><td colspan="2" class="no ip_alert">\n);

#書き込むと、あなたの接続データ \( ) . Escape::HTML([$ENV{'REMOTE_ADDR'}]) . qq( \） が内部に保存されます。

# 投稿上の注意 ( 本文 )
my 	$alert_text_body = qq(<span class="ip_alert alert">★必ず <a href="rule.html" target="_blank" class="blank">ローカルルール</a> や <a href="$basic_init->{'guide_url'}%A5%E1%A5%D3%A5%A6%A5%B9%A5%EA%A5%F3%A5%B0%B6%D8%C2%A7" target="_blank" class="blank">メビウスリングのルール</a> をご覧ください。</span>);

	# スマフォ版
	if($my_use_device->{'smart_flag'}){
		$alert_text .= qq(<div id="ip_alert_natural" class="ip_alert">);
		$alert_text .= qq(<a href="javascript:vinline('ip_alert_hidden');vnone('ip_alert_natural');" class="red fold">★投稿上のご注意</a>);
		$alert_text .= qq(</div>);
		$alert_text .= qq(<div id="ip_alert_hidden" class="display-none">);
		$alert_text .= qq($alert_text_body);
		$alert_text .= qq( <a href="javascript:vinline('ip_alert_natural');vnone('ip_alert_hidden');" class="fold">×閉じる</a> );
		$alert_text .= qq(</div>);
	}
	# デスクトップ版
	else{
		$alert_text .= qq($alert_text_body);
	}

	# 記事ごとの警告（管理者設定）
	if($main_thread->{'concept'} =~ /Alert-violation/){

		# 削除情報を分解
		my(undef,undef,$lasttime,$reason) = split(/=/,$d_delman);
		require "${init_directory}part_delreason.pl";
		my($reason_text,$reason_subject,$reason_comment,$operation) = &delreason($reason,undef,$main_thread->{'sub'},$head_title);
			# 管理者設定から１週間以内の場合
			if($lasttime + 30*24*60*60 >= time && $reason){
				$alert_text .= qq(<br$main::xclose><br$main::xclose>);
				$alert_text .= qq(<div class="thread_alert1">管理者からのメッセージ（重要）　 - $reason_subject -</div>);
				$alert_text .= qq(<div class="thread_alert2">);
				#$alert_text .= qq(<span class="red">【$reason_subject】</span><br$main::xclose>);
				$alert_text .= qq($reason_comment);
				$alert_text .= qq(<br$main::xclose>不適切な状態が続く場合、記事をロック/削除させていただく場合があります。);
					if($operation){ $alert_text .= qq(<br$main::xclose>　<span class="red">→対策： $operation </span>); }
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
# デスクトップ版 プレビューとエラー
#-----------------------------------------------------------
sub regist_rerror{

# 宣言
my($regist_type);
our($echeck_flag,$css_text);
my($init_directory) = Mebius::BaseInitDirectory();
my($my_use_device) = Mebius::my_use_device();
my($init_bbs) = Mebius::BBS::init_bbs_parmanent_auto();
my($param) = Mebius::query_single_param();
my($thread_view_line);

# エラー時アンロック
if($lockflag) { &unlock($lockflag); }


	# スマフォ版
	if($my_use_device->{'smart_flag'}){
		$main::css_text .= qq(.body1{width:100%;}\n);
	}

# 各表示エリアをセット
my($fasterror_line) = rerror_set_fasterror(@_);
my($preview_line,$index_preview_line) = preview_area_resform($use);
my($error_line) = rerror_set_error($e_com);
my($data_line) = rerror_set_data();

	# 画像添付エリア
	if($init_bbs->{'concept'} =~ /Upload-mode/){ upload_setup(); }

	# 注意文
	if(!$e_com && !$_[0]){
		$please_line = qq(	<strong class="mada">	●まだ書き込まれていません。 <input type="submit" value="この内容で送信する"> を押すか、編集フォームで内容を変更してください。</strong><br><br>);
	}

# タイトル定義
$sub_title = qq(投稿 | $title);

	# 編集フォームを表示
my($new_mode,$res_mode);
	if($in{'res'}){ $res_mode = 1; }
	else{ $new_mode = 1; }
	require "${init_directory}part_resform.pl";
	my($resform_line) = bbs_thread_form({ Preview => 1 , NewMode => $new_mode , ResMode => $res_mode , NotSetFormTag => 1 });

	# 元のスレッドを表示 ( レス投稿時のみ )
	if($param->{'no'} ne ""){
		require "${init_directory}part_view.pl";
		($thread_view_line) = main::bbs_view_thread({ Preview => 1 });
	}


my $print .= $thread_view_line;

# フォーム始まり
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

# ナビゲーションリンク
# ナビゲーションリンク
my($navi_links2) = shift_jis(Mebius::BBS::thread_navigation_links({ bbs_kind => $main::moto , thread_number => $main::in{'res'} },{ Bottom => 1 }));

$print .= $navi_links2;

# ページ終わり
$print .= qq($resform_line);
$print .= qq(</form>);

# フッタ
	# フッタ
	if($my_use_device->{'smart_flag'} || Mebius::alocal_judge()){
		Mebius::Template::gzip_and_print_all({ Jquery => 1 , javascript_files => ['jquery.flicksimple'] },$print);
	} else {
		Mebius::Template::gzip_and_print_all({},$print);
	}

exit;

}

#-----------------------------------------------------------
# 即時エラー
#-----------------------------------------------------------
sub rerror_set_fasterror{

# 局所化
my($line);

# リターン
if($_[0] eq ""){ return; }

# 表示内容
$line = qq(
<div class="special_error">
<strong class="red">特殊エラー：</strong><br>
▼$_[0]<br>
▼メッセージに従っても状況が改善されない場合は、${mailform}からご連絡いただけます。<br>
　「エラーが起きた場所」「記事のＵＲＬ」「正確なエラーメッセージ」など詳しい情報をお伝えください。<br>
</div><br>
);

return($line);

}


#--------------------------------------------------------------
# 投稿エラー
#--------------------------------------------------------------
sub rerror_set_error{

# 局所化
my $error = shift;
my($line,$error_text,$pleasechange_text);

	# リターン
	if(!$error){ return; }

# エラー内容
$error_text = "$error";

# エラー表示
$line = qq(
<div class="error_line">
<span class="red">エラー： </span><br>
$error_text
$pleasechange_text
</div>
<br>
);

return($line);

}

#--------------------------------------------------------------
# 予告データ
#--------------------------------------------------------------
sub rerror_set_data{

# 局所化
my($up,$line,$pre_sub,$rer_option,$news_option,$next_charge);
my($my_account) = Mebius::my_account();
our($nextcharge_minsec,$cgold,$pmfile,%in);

	# リターン
	if($_[0] || $strong_emd){ return; }

	# 新規投稿であれば（投稿データ内容に追加）
	if($in{'res'} eq ""){ $pre_sub = " &gt; <strong>新しい記事</strong>"; }

	# レス投稿の場合、文字数データを表示
	if($in{'res'} ne ""){
		$next_charge .= qq(　<strong>→</strong>　次回チャージは $nextcharge_minsec です$text);
			if($norank_wait){ $next_charge .= qq( (一律)); }
			elsif($cgold >= 1){ $next_charge .= qq(　( 金貨の影響で有利に )); }
			elsif($cgold <= -1){ $next_charge .= qq(　( 金貨の影響で不利に )); }
	}

	# アップするかしないか
	if($in{'res'} ne ""){
			if($in{'up'} eq "1"){ $rer_option = qq(　オプション： 記事を<strong class="red">アップ</strong>); }
			else{ $rer_option = qq(　オプション： なし);}
	}


	# トップ掲載
	#if($in{'news'}){ $news_option = qq( / トップ掲載する); }
	#else{ $news_option = qq( / トップ掲載しない); }


# 投稿データ内容 を定義
$line = qq(<div class="data_line">);
$line .= qq(<strong class="middle">$smlength文字</strong> を投稿);


#if($cgold ne ""){ $line .= qq( ( +<img src="/pct/icon/gold1.gif" alt="金貨" title="金貨"> 現$cgold枚 ) ); }
$line .= qq($next_charge);
#$line .= qq(<br$main::xclose>投稿先： <a href="./">$title</a> $pre_sub $rer_option $news_option);
$line .= qq(</div><br>);

return($line);

}

#use strict;

#--------------------------------------------------------------
# プレビュー
#--------------------------------------------------------------
sub preview_area_resform{

# 局所化
my $use = shift;
my($line,$index_preview_line,$pre_res,$name,$id,$trip,$preview_title);
my(%image,$image_preview);
my $query = new CGI;
our($new_res_concept);
my($basic_init) = Mebius::basic_init();
my($my_account) = Mebius::my_account();
my($now_date) = Mebius::now_date();

# 整形
$trip = qq(☆トリップ) if $enctrip;

	my($id_history_judge) = Mebius::BBS::id_history_level_judge({ from_encoding => "sjis" });
	if($id_history_judge->{'record_flag'}){
		$id = qq(<i><a href="./" class="idory" target="_blank" class="blank">★).e($encid).qq(</a></i>);
	}
	else{
		$id = qq(<i>★).e($encid).qq(</i>);
	}

$pre_res = $query->param('pre_res') + 1;
$name = "$i_handle$trip";
	if($my_account->{'login_flag'} && $query->param('account_link')){ $name = qq(<a href="$basic_init->{'auth_url'}$my_account->{'id'}/" target="_blank" class="blank">$name</a>);} 

# 文章エフェクト
($i_com) = Mebius::Effect::all($i_com);

# オートリンク
($i_com) = &bbs_regist_auto_link($i_com);

# レスjコンセプトでの整形
my($comment_style) = Mebius::BBS::CommentStyle(undef,$new_res_concept);

# プレビュー宣言
$preview_title = qq(<div class="preview_line">プレビュー</div><br>);

	# おえかき画像
	if($in{'image_session'}){
		(%image) = Mebius::Paint::Image("Get-hash Post-check",$in{'image_session'});
			if($image{'post_ok'}){
				$image_preview .= qq(<div class="paint_image">);
				$image_preview .= qq(<a href=").e($image{'image_url_buffer'}).qq(">);
				$image_preview .= qq(<img src=").e($image{'samnale_url_buffer'}).qq(" alt="添付画像">);
				$image_preview .= qq(</a>);
				$image_preview .= qq(</div>);
			}

	}

	# 新規投稿の場合
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

	# レス投稿の場合
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


	# INDEX プレビュー
	if($use->{'NewMode'}){
		$index_preview_line = qq(
		<table cellpadding="3" summary="記事一覧" class="table2 bbs">
		<tr><th class="td0">印</th><th class="td1">題名</th><th class="td2">名前</th><th class="td3">最終</th><th class="td4"><a name="go"></a>返信</th></tr>
		<tr><td><a href="./">★</a></td><td><a href="./">).e($i_sub).qq(</a></td><td>).e($i_handle).qq(</td><td>).e($i_handle).qq(</td><td>0回</td></tr>
		</table>
		);
	}



return($line,$index_preview_line);

}

1;


1;

