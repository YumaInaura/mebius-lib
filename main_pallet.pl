
use strict;
use Mebius::Paint;
package Mebius::Pallet;
use Mebius::BBS;

#-----------------------------------------------------------
# 共モジュール通の設定
#-----------------------------------------------------------
sub Init{

my(%init);

# スキンのあるディレクトリ
if($main::admin_mode){ $init{'skin_directory'} = "/skin/"; }
else{ $init{'skin_directory'} = "../skin/"; }

if($main::server_domain =~ /^(aurasoul.mb2.jp|mb2.jp|localhost)$/){ $init{'paintmain_mode'} = 1; }

return(%init);

}

#-----------------------------------------------------------
# お絵かきパレット
#-----------------------------------------------------------
sub Start{

# タイトル定義
$main::sub_title = "お絵かきパレット";
$main::head_link1 = qq( &gt; <a href="${main::main_url}newpaint-p-1.html">お絵かき</a> ); 
$main::head_link2 = qq( &gt; <a href="./?mode=pallet">マイピクチャ</a> ); 

# 金貨がマイナスの場合
if($main::cgold <= -1 && !$main::myadmin_flag && !$main::alocal_mode){ main::error("金貨がマイナスのため、お絵かきできません。","","","Not-repair"); }

# 独自Cookieを取得
our($cookie_concept,$cookie_session,$cookie_password) = undef;
my($cookie) = Mebius::get_cookie("Paint");
our($cookie_concept,$cookie_session,$cookie_password) = @$cookie;

# 正規URL
$main::canonical = "${main::main_url}pallet.html";

	# モード切り替え
	if($main::submode2 eq "viewer" || $main::submode2 eq "animation"){ &Viewer(); }
	elsif($main::in{'type'} eq "edit"){ &Edit(); }
	elsif($main::in{'type'} eq "posted" || $main::in{'type'} eq "editor"){ &After_page(); }
	elsif($main::in{'type'} eq "pallet"){ &Pallet_page(); }
	elsif($main::in{'type'} eq "list_delete"){ &List_delete(); }
	elsif($main::in{'type'} eq "image_delete"){ &Image_delete(); }
	else{ &Before_page(); }

exit;

}

#-----------------------------------------------------------
# 絵の編集
#-----------------------------------------------------------
sub Edit{

	# 設定の取り込み
	my(%init) = &Init();

	# アクセス制限
	main::axscheck();

	# エラーチェック
	if($main::in{'image_session'} eq ""){ main::error("お絵かきIDを指定してください。"); }
	if(length($main::in{'image_title'}) >= 20*2){ main::error("絵のタイトルは最大２０文字までです。（全角）"); }
	if($main::in{'image_title'} =~ /^(\x81\x40|\s)+$/ || $main::in{'image_title'} eq ""){ main::error("絵のタイトルを入力してください。"); }
	if(length($main::in{'comment'}) >= 2000*2){ main::error("絵の説明文は最大2000文字までです。（全角）"); }

	# 本文のチェック
	require "${main::int_dir}regist_allcheck.pl";
	($main::in{'comment'}) = main::all_check(undef,$main::in{'comment'},$main::in{'name'});
	if($main::e_com){ main::error("$main::e_com"); }

	# 編集を実行
	Mebius::Paint::Image("Edit-data Renew-logfile-buffer",$main::in{'image_session'});

	# このまま絵を確定させる場合
	if($main::in{'submit_type'} eq "soon" && $init{'paintmain_mode'}){

		my(%image) = Mebius::Paint::Image("Get-hash Post-check",$main::in{'image_session'});
		if($image{'post_ok'}){ }
		else{ main::error("▼このお絵かき画像は既に投稿済み、もしくは保存期限が切れています。"); }

		# お絵かき画像を確定させる
		my $resnumber_random = $main::time . int(rand(999));
		Mebius::Paint::Image("Rename-justy Renew-logfile-justy",$main::in{'image_session'},undef,$main::server_domain,"mpaint",$main::thisyear,$resnumber_random);
		Mebius::Paint::Image("Posted Renew-logfile-buffer",$main::in{'image_session'});

	}

	# クッキーをセット
	Mebius::Cookie::set_main({ name => $main::in{'name'} },{ SaveToFile => 1 });

	# 投稿確定した場合のリダイレクト
	if($main::in{'submit_type'} eq "soon"){
		Mebius::Redirect("","${main::main_url}newpaint-p-1.html");
	}

	# クッキーがあり、元ページにリダイレクトする場合
	elsif($main::in{'backurl'} && $main::backurl){
		Mebius::Redirect("",$main::backurl);
	}

	# その他の場合のリダイレクト
	else{
		Mebius::Redirect("","${main::main_url}?mode=pallet");
	}

exit;

}


#-----------------------------------------------------------
# お絵かき後のページ
#-----------------------------------------------------------
sub After_page{

# 宣言
my($line,$input_image_title,$input_comment);
my($not_form_flag);

# 設定の取り込み
my(%init) = &Init();

# CSSを定義
$main::css_text .= qq(
textarea{width:400px;height:100px;}
td{vertical-align:top;}
div.post_guide{padding:1em;background:#fee;font-size:90%;margin:1em 0em;}
);

# タイトル定義
$main::head_link3 = qq(&gt; お絵かき完了);

# お絵かきIDをクッキーにセット
Mebius::Paint::Image("Set-cookie-session Get-cookie",$main::in{'image_session'});

		#Mebius::Redirect("","${main::main_url}?mode=pallet&posted=1&backurl=$main::backurl_enc");

# 画像取得
my(%image) = Mebius::Paint::Image("Get-hash Post-check",$main::in{'image_session'});

	# 説明文
	if(time < $image{'lasttime'} + 3*60){
		$line .= qq(絵を<strong class="red">一時保存</strong>しました。（まだ投稿されていません）);
		$line .= qq(<br$main::xclose><br$main::xclose>);
	}

# 画像を表示
$line .= qq(<img src="$image{'image_url_buffer'}"$main::xclose>);

# 2012/3/27 (火)
Mebius::AccessLog(undef,"Paint-buffer-data-saved","お絵かきID : $main::in{'image_session'} / URL : $image{'image_url_buffer'}");

# ステップ数を表示
#$line .= qq(<br$main::xclose><br$main::xclose>);
#$line .= qq(ステップ数： $image{'all_steps'});

		# ステップ数が足りない場合
		if($image{'must_steps'} - $image{'all_steps'} >= 1){
			$line .= qq(<br$main::xclose><br$main::xclose><span class="alert">※このままでは投稿確定できません。);
			$line .= qq(もう少し丁寧に<a href="./?mode=pallet#CONTINUE">続きから描き直して</a>ください。($image{'all_steps'} ステップ / $image{'must_steps'} ステップ )</span>);
			$not_form_flag = 1;
		}
		
# ペイント時間を表示
#$line .= qq(<br$main::xclose>);
#$line .= qq(ペイント時間： $image{'all_painttime'}秒);

		# ペイント時間が足りない場合
		if($image{'must_painttime'} - $image{'all_painttime'} >= 1){
			$line .= qq(<br$main::xclose><br$main::xclose><span class="alert">※このままでは投稿確定できません。);
			$line .= qq(もう少し丁寧に<a href="./?mode=pallet#CONTINUE">続きから描き直して</a>ください。（ $image{'all_painttime'}病 / $image{'must_painttime'}秒 ）</span>);
			$not_form_flag = 1;
		}

# 初期入力内容を定義
$input_image_title = $image{'title'};
$input_comment = $image{'comment'};
$input_comment =~ s/<br>/\n/g;

	# フォーム
	if(!$not_form_flag || $main::alocal_mode){

		#$line .= qq(<h2>タイトル付け</h2>);

		# 説明
		$line .= qq(<div class="post_guide">絵にタイトルを付けると、);
			if($main::in{'backurl'}){ $line .= qq(<a href="$main::backurl_href">掲示板のフォーム</a>); }
			else{ $line .= qq(掲示板のフォーム); }
		$line .= qq(で添付したい絵を選べるようになります。);
		$line .= qq(このまま<a href="./?mode=pallet#CONTINUE">続きから描く</a>ことも出来ます。</div>);

		$line .= qq(<form action="./" method="post">
		<div>

		<input type="hidden" name="mode" value="pallet"$main::xclose>
		<input type="hidden" name="type" value="edit"$main::xclose>
		<input type="hidden" name="image_session" value="$main::in{'image_session'}"$main::xclose>);

		# 戻り先
		if($main::in{'backurl'}){ $line .= qq($main::backurl_input\n); }

		$line .= qq(<table>

		<tr>
		<td><label for="image_title">絵のタイトル</label></td>
		<td><span class="alert">※必須</span></td>
		<td><input type="" name="image_title" value="$input_image_title" id="image_title"$main::xclose></td>
		</tr>

		<tr>
		<td><label for="name">筆名</label></td>
		<td><span class="alert">※必須</span></td>
		<td><input type="text" name="name" value="$main::cnam" id="name"$main::xclose></td>
		</tr>

		<tr>
		<td><label for="comment">絵の説明</label></td>
		<td><span class="guide">※省略可</span></td>
		<td><textarea name="comment" id="comment">$input_comment</textarea></td>
		</tr>

		<tr>
		<td></td>
		<td></td>
		<td>
		<input type="submit" name="action" value="この内容で送信する" class="isubmit"$main::xclose>);

		# そのまま確定チェック
			if($init{'paintmain_mode'} && ($image{'post_ok'} || $main::alocal_mode)){
				#$line .= qq(<br$main::xclose>\n);
				$line .= qq( <input type="radio" name="submit_type" value="save" id="submit_save"$main::parts{'checked'}$main::xclose>);
				$line .= qq( <label for="submit_save">掲示板用に保存</label>\n);
				$line .= qq(<input type="radio" name="submit_type" value="soon" class="isubmit" id="submit_soon"$main::xclose>);
				$line .= qq( <label for="submit_soon">このまま絵を確定</label>\n);
				$line .= qq( ( <span class="guide">※<a href="${main::main_url}newpaint-p-1.html" class="blank" target="_blank">新着一覧</a>にのみ表\示されます )</span>);
			}

		$line .= qq(
		</td>
		</tr>

		</table>
		</div>
		</form>
		);

	}



# HTML
my $print = $line;

Mebius::Template::gzip_and_print_all({},$print);


exit;

}

#-----------------------------------------------------------
# 確認ページ
#-----------------------------------------------------------
sub Before_page{

# 宣言
my($line,$plus_pallet_checked,$animation_checked,$animation_checked,$continue_checked_flag,$continue_checked,$newpost_checked);
my($submit_button,$method,$applet_pro_checked,$applet_normal_checked,$agree_checked1,$agree_checked2);
our($cookie_concept,$cookie_session);

# タイトル定義
$main::head_link2 = qq(&gt; マイピクチャ);

# 送信ボタン
$submit_button = qq(<input type="submit"  value="お絵かきする" class="paint_next">);

# CSS定義
$main::css_text .= qq(
.paint_next{font-size:120%;border:solid 1px #000;background:#fff;}
strong.alert{font-size:120%;}
);

# フォーム開始
if($main::myadmin_flag){ $method = "get"; }
else{ $method ="post"; }
$line .= qq(<form action="./?mode=pallet" method="$method"$main::sikibetu>);
$line .= qq(<div>);

# 表示部分
$line .= qq(<h1>お絵かきする</h1>);
$line .= qq(<span class="guide">ここで描いた絵は、掲示板への投稿時に使えます。詳しくは<a href="${main::guide_url}%A4%AA%B3%A8%A4%AB%A4%AD%B5%A1%C7%BD">お絵かきガイド</a>をご覧ください。（<a href="http://aurasoul.mb2.jp/_qst/2556.html">→質問/連絡記事</a>）</span>);


# 利用規約に同意
if($cookie_concept =~ /Agree-alert/){ $agree_checked1 = $main::parts{'checked'}; }
$line .= qq(<br$main::xclose><br$main::xclose><input type="checkbox" name="agree1" value="on" id="agree1"$agree_checked1> <label for="agree1"><span class="alert">私は「雑すぎる絵」「文字のみの絵」「性的/ショッキングな絵」「記事に関係のない絵」などサイトルールに反するものは投稿しません。</span></label>\n);

# 利用規約に同意
if($cookie_concept =~ /Agree-alert/){ $agree_checked2 = $main::parts{'checked'}; }
$line .= qq(<br$main::xclose><br$main::xclose><input type="checkbox" name="agree2" value="on" id="agree2"$agree_checked2> <label for="agree2"><span class="alert">私は <strong class="alert">既存ゲーム/アニメ等のキャラクター</strong> は描きません。著作権/肖像権守って利用します。(著作権フリーのものをのぞく)</span></label><br$main::xclose>\n);

# 絵の名前
$line .= qq(<br$main::xclose> $submit_button <br$main::xclose>\n);

# オプションの選択
$line .= qq(<h2>オプション</h2> );

$line .= qq(<input type="hidden" name="mode" value="pallet">\n);
$line .= qq(<input type="hidden" name="type" value="pallet">\n);
#$line .= qq(<input type="hidden" name="moto" value="$main::in{'moto'}">\n);
#$line .= qq(<input type="hidden" name="no" value="$main::in{'no'}">\n);


# 拡張パレットの選択
if($cookie_concept =~ /Plus-pallet-on/){ $plus_pallet_checked = $main::parts{'checked'}; }
$line .= qq(<input type="checkbox" name="plus_pallet" value="on" id="plus_pallet"$plus_pallet_checked> <label for="plus_pallet">拡張パレットを使う</label><br$main::xclose>\n);

# アニメーションの選択
if($cookie_concept =~ /Animation-on/ || $cookie_concept eq ""){ $animation_checked = $main::parts{'checked'}; }
$line .= qq(<input type="checkbox" name="animation" value="on" id="animation"$animation_checked> <label for="animation">アニメーションを記録する</label><br$main::xclose>\n);



# 差し替え禁止
$line .= qq(<input type="checkbox" name="deny_sasikae" value="1" id="deny_sasikae"> <label for="deny_sasikae">今後の差し替えを禁止する</label><br$main::xclose>);

# キャンバスのサイズ
$line .= qq(<br$main::xclose>キャンバスのサイズ： );
	my(@canvas_size) = Mebius::Paint::Canvas_size();
	foreach(@canvas_size){
		my $checked = $main::parts{'checked'} if($_ == 300);
		$line .= qq(<input type="radio" name="canvas_size" value="${_}x${_}" id="canvas_size${_}x${_}"$checked>);
		$line .= qq(<label for="canvas_size${_}x${_}">${_}x${_}</label>\n);
	}

# アプレットの選択
	if($cookie_concept =~ /Painter-pro/){ $applet_pro_checked = $main::parts{'checked'}; }
	else{ $applet_normal_checked = $main::parts{'checked'}; }
$line .= qq(<br$main::xclose><br$main::xclose>アプレット： );
$line .= qq(<input type="radio" name="applet" value="" id="applet-normal"$applet_normal_checked> <label for="applet-normal">しぃペインター</label>\n);
$line .= qq(<input type="radio" name="applet" value="pro" id="applet-pro"$applet_pro_checked> <label for="applet-pro">しぃペインタープロ</label>\n);


$line .= qq(<br$main::xclose>);

# 投稿ボタン
#$line .= qq(<br$main::xclose><br$main::xclose>$submit_button);

	# ●「続きから描く」を表示
	$line .= qq(<h2 id="CONTINUE">続きから描く場合</h2> );

	$line .= qq(出来上がった絵は… );
	$line .= qq(<input type="radio" name="continue_type" value="sasikae" id="sasikae"$main::parts{'checked'}> <label for="sasikae">以前の絵と差し替える</label>);
	$line .= qq(<input type="radio" name="continue_type" value="new" id="sinnki"> <label for="sinnki">新規絵扱いにする</label><br$main::xclose><br$main::xclose>);


	# 新しく描く
	if(!$main::in{'continue'}){ $newpost_checked = $main::parts{'checked'}; }
	$line .= qq(<input type="radio" name="continue_session" value="" id="not_continue"$newpost_checked> <label for="not_continue">未選択</label><br$main::xclose>);

	# クッキーの配列を展開
	foreach(split(/\s/,$cookie_session)){

		# 複数のお絵かきID（セッション名）からそれぞれ、画像URL等のデータを取得
		my(%image) = Mebius::Paint::Image("Get-hash Post-check",$_);

			# 一時画像が存在する場合
			if($image{'continue_ok'}){

					# 一番新しい画像に初期チェックを入れる
					if(!$continue_checked_flag && $main::in{'continue'}){
						$continue_checked = $main::parts{'checked'};
						$continue_checked_flag = 1;
					}

				# ラジオボックス、バッファ画像のサムネイルを表示
				$line .= qq(<br$main::xclose><hr><br$main::xclose><input type="radio" name="continue_session" value="$image{'session'}" id="session-$image{'session'}"$continue_checked>);
				$line .= qq(<label for="session-$image{'session'}"> お絵かきID： $image{'session'} の続きから描く。</label>\n);
				$line .= qq(<br$main::xclose>);
				$line .= qq(<a href="$image{'image_url_buffer'}" target="_blank" class="blank"><img src="$image{'samnale_url_buffer'}" alt="描きかけの画像" class="noborder"></a>\n);
						if($image{'deny_sasikae'}){ $line .= qq( <span class="red">(差し替え禁止)</span>); }
						if($image{'image_posted'}){ $line .= qq( <span class="blue">(投稿済み)</span>); }
				$line .= qq( <span class="guide">保存期限 ： あと$image{'lefthour'}時間</span>);
				$line .= qq(　<a href="./?mode=pallet&amp;type=list_delete&amp;image_session=$image{'session'}">一覧から削除</a>);
					if(!$image{'image_posted'}){ $line .= qq(　<a href="./?mode=pallet&amp;type=editor&amp;image_session=$image{'session'}">→タイトル付け</a>); }
				$line .= qq(<br$main::xclose>);
			}
			
			# 保存期限の超過など、続きから描けない場合
			#elsif($main::myadmin_flag >= 5){
			#	$line .= qq(・お絵かきID： $image{'session'} は保存期限が過ぎています。\n);
			#	$line .= qq(<br$main::xclose>\n);
			#}
	}

	# 手打ちの入力ボックス
	$line .= qq(<input type="radio" name="continue_session" value="select_by_text"> );
	$line .= qq(お絵かきID：<input type="text" name="continue_session_text" value=""> の続きから描く。（半角英数字を手打ちで入力してください）<br$main::xclose>);

	# 戻り先URL
	if($main::in{'backurl'}){ $line .= qq($main::backurl_input); }

# パスワードの入力
#$line .= qq(<input type="password" name="password" value="$cookie_password">);

$line .= qq(<br$main::xclose><br$main::xclose>$submit_button\n);

$line .= qq(</div>);
$line .= qq(</form>);


Mebius::Template::gzip_and_print_all({},$line);

}

#-----------------------------------------------------------
# パレットページ全体
#-----------------------------------------------------------
sub Pallet_page{

# 宣言
my($pallet_line,$set_cookie_concept);
our($cookie_session,$cookie_password);

# タイトル定義
$main::head_link4 = qq(&gt; パレット);

# アクセス制限
main::axscheck("");

# 第二CのSSを定義
push(@main::css_files,"pallet");

	# ▼独自Cookieをセット
	# 壊れた Cookieを切り取り 2012/3/25 (日)
	if(length $cookie_session >= 1000){ $cookie_session = substr $cookie_session , 0 , 100; }
	if($main::in{'animation'} eq "on"){ $set_cookie_concept .= qq( Animation-on); }
	if($main::in{'plus_pallet'} eq "on"){ $set_cookie_concept .= qq( Plus-pallet-on); }
	if($main::in{'applet'} eq "pro"){ $set_cookie_concept .= qq( Painter-pro); }
	if($main::in{'agree1'} eq "on" && $main::in{'agree2'}){ $set_cookie_concept .= qq( Agree-alert); }

Mebius::set_cookie("Paint",[$set_cookie_concept,$cookie_session,$cookie_password]);

# パレットを取得
($pallet_line) = Mebius::Pallet::Pallet();

# Javascriptを取得
Mebius::Pallet::Head_javascript();

Mebius::Template::gzip_and_print_all({},$pallet_line);

}

#-----------------------------------------------------------
# お絵かきパレット
#-----------------------------------------------------------
sub Pallet{

# 宣言
my($security_timer,$applet,$plus_pallet1,$plus_pallet2);

# アプレットを取得
($applet) = &Applet();

	# 拡張パレットを取得
	if($main::in{'plus_pallet'} eq "on"){
		($plus_pallet1) = &Plus_pallet1();
		($plus_pallet2) = &Plus_pallet2();
	}

# ボディー
my $line = qq(
<div align="center"> 

<span class="alert">＊迷惑行為があった場合、即刻 <strong>投稿制限</strong> させて頂く場合があります。</span><br$main::xclose>);

# 使い方ガイド
$line .= qq(<span class="guide">ガイド： );

	#if($main::in{'applet'} eq "pro"){
	#	$line .= qq(<a href="http://piclab.sakura.ne.jp/kouza2/kihonP/menu.htm" target="_blank" class="blank">しぃペインタープロの使い方</a> (外部サイト));
	#}
	#else{
	#	$line .= qq(<a href="http://piclab.sakura.ne.jp/kouza2/kihonH/menu.htm" target="_blank" class="blank">しぃペインターの使い方</a> (外部サイト));
	#}

	$line .= qq(<a href="http://oekakiart.net/kouza/020shipainter/" target="_blank" class="blank">しぃペインターの使い方</a> (外部サイト));

# JAVAインストール
$line .= qq( / 動作しない場合は <a href="http://www.java.com/ja/" class="blank" target="_blank">JAVAをインストール</a> してください。 );


$line .= qq(</span><br$main::xclose><br$main::xclose>);

$line .= qq(
<table><tr> 
<td align="right valign-top"> 
$plus_pallet1
</td> 
<td class=" align-top" style="padding:0em 1em;">
$applet

</td> 
<td class="valign-top"> 
$plus_pallet2

</td></tr></table> 


</div> 

);
 
# 著作権表示
$line .= qq(
<br> 
<div align=right class="nextback">
<a href="http://hp.vector.co.jp/authors/VA016309/spainter/" title="しぃ堂" target="_blank" class="blank"> 
+Paint-Applet &copy; Shi-dow</a>
</div>

);

return($line);


#-----------------------------------------------------------
# お絵かきアプレット部分
#-----------------------------------------------------------
sub Applet{

# 宣言
my(%init) = &Init();
my($line,$image_session,$animation_flag);
my(%image,$sasikae_flag,$continue_flag,$continue_flag,$continue_session,$url_save,$continue_type);
my($image_title,$applet_width,$applet_height,$backurl_pallet,$super_id,$applet_url);
my($image_size,$compress_level,$image_width,$image_height,$deny_sasikae_flag,$image_title_enc,$url_exit);

# CSS定義
$main::css_text .= qq(
div.valaety_data{line-height:1.4em;margin:1em auto;width:80%;}
);

	# 規約への同意をチェック
	if($main::in{'agree1'} eq "on" && $main::in{'agree2'} eq "on"){ }
	else{ main::error("規約への同意がないと、お絵かき出来ません。"); }

# 画像セッションID
($image_session) = Mebius::Crypt::char("",12);

	# 続きから描く場合、各種データを取得

	# テキストで手打ちした場合
	if($main::in{'continue_session'} eq "select_by_text"){
		$continue_session = $main::in{'continue_session_text'};
	}
	# ラジオボックスより指定した場合
	elsif($main::in{'continue_session'}){
		$continue_session = $main::in{'continue_session'};
	}
	# コンティニューのためにバッファ・ログデータをチェック 
	if($continue_session){
		(%image) = Mebius::Paint::Image("Get-hash Get-cookie",$continue_session);
			if(-e $image{'animation_file_buffer'}){	$continue_flag = 1; }
	}

# フォームを開いてから～秒以内の送信を禁止
#$security_timer = 180;
#if($main::alocal_mode || $main::myadmin_flag){ $security_timer = 0; }

	# 分解
	my($canvas_select_width,$canvas_select_height) = split(/x/,$main::in{'canvas_size'});

	# キャンバスの横幅
	$image_width = 300;
	if($image{'width'}){ $image_width = $image{'width'}; }								# コンティニュー
	elsif($main::in{'image_width'}){ $image_width = $main::in{'image_width'}; }			# 手打ちで指定
	elsif($canvas_select_width){ $image_width = $canvas_select_width; }					# テンプレから指定

	# キャンバスの縦幅
	$image_height = 300;
	if($image{'height'}){ $image_height = $image{'height'}; }							# コンティニュー
	elsif($main::in{'image_height'}){ $image_height = $main::in{'image_height'}; }		# 手打ちで指定
	elsif($canvas_select_height){ $image_height = $canvas_select_height; }				# テンプレから指定

	# キャンバスサイズの違反チェック
	my($error_flag_canvassize) = Mebius::Paint::Canvas_size("Violation-check",$image_width,$image_height);
	if($error_flag_canvassize){ main::error("$error_flag_canvassize"); }

	# アプレット本体の表示サイズ
	$applet_width = 490;
	$applet_height = 450;
	if($image_width >= 400){ $applet_width = $image_width + 90 + 50; }
	if($image_height >= 400){ $applet_height = $image_height + 50 + 50; }
	if($main::in{'applet'} eq "pro"){ $applet_width += 100; }
	if($main::in{'applet'} eq "pro"){ $applet_height += 100; }

	# 差し替え禁止
	if($main::in{'deny_sasikae'}){ $deny_sasikae_flag = 1; }

	# アニメーションの記録オン/オフ
	if($main::in{'animation'} eq "on"){ $animation_flag = 1; }

	# 投稿用スクリプト
	if($main::alocal_mode){ $url_save = "/cgi-bin/getpics.cgi"; }
	else{ $url_save = "/main/getpics.cgi"; }

	# 「続きから描く」→「新規絵扱い」時のスーパーID
	if($continue_flag && $main::in{'continue_type'} eq "new"){ $super_id = $image{'super_id'}; }

	# 絵につける名前
	if($main::in{'image_title'}){
		($image_title_enc) = Mebius::Encode("",$main::in{'image_title'});
		$image_title = $main::in{'image_title'};
	}
	elsif($continue_flag){
		$image_title = $image{'title'};
		($image_title_enc) = Mebius::Encode("",$image{'title'});
	}

# アプレットの選択
if($main::in{'applet'} eq "pro"){ $applet_url = "$init{'skin_directory'}spainter.jar,$init{'skin_directory'}pro.zip"; }
else{ $applet_url = "$init{'skin_directory'}spainter.jar,$init{'skin_directory'}normal.zip"; }


# アプレット開始
$line .= qq(
<!--↓ここからアプレット--> 
<applet mayscript code="c.ShiPainter.class" archive="$applet_url" name="paintbbs" style="width:${applet_width}px;height:${applet_height}px;"> 
<param name="header_magic" value="S"> 
<param name="url_save" value="$url_save">\n);

	# 続きデータを入力した場合
	if($continue_flag){

			# 続きから描くけれど、新規投稿にする場合
			if($main::in{'continue_type'} eq "new"){
				$continue_type = "new";
			}

			# 続きから描き、差し替えする場合（お絵かきIDを一緒に）
			elsif($main::in{'continue_type'} eq "sasikae"){
					if($image{'deny_sasikae'}){ main::error("この絵は差し替え禁止です。新規投稿を選んでください。"); }
				$continue_type = "sasikae";
				$image_session = $image{'session'};
				$sasikae_flag = 1;
			}
			else{ main::error("差し替えか新規投稿を選んでください。"); }

		$line .= qq(<param name="pch_file" value="$image{'animation_url_buffer'}">\n);
	}

	# 投稿後に移動するURL
	if($main::in{'backurl'}){ $backurl_pallet = $main::backurl_enc; }
	$url_exit = "${main::main_url}?mode=pallet&amp;type=posted&amp;image_session=$image_session&amp;backurl=$backurl_pallet";
	$line .= qq(<param name="url_exit" value="$url_exit">\n);


	# 圧縮レベル
	if($image{'compress_level'}){
		$compress_level = $image{'compress_level'};
	}
	elsif($main::in{'plus_pallet'} eq "on"){
		$compress_level = 7;	# 値が小さい方が”高”画質
		$image_size = 100;
	}
	else{
		$compress_level = 15;	# 値が大きい方が”低”画質
		$image_size = 60;
	}


	# 拡張ヘッダ
	$line .= qq(<param name="send_header" value=");
	$line .= qq(image_session=$image_session&super_id=$super_id&pass=&name=&applet=shipainter&width=$image_width&height=$image_height);
	$line .= qq(&anime=1&pchsave=1&painttime=&paintstarttime=$main::time&ptimeoff=&quality=1&animation_on=$animation_flag&sasikae=$sasikae_flag);
	$line .= qq(&deny_sasikae=$deny_sasikae_flag&continue_type=$continue_type&image_title=$image_title_enc);
	$line .= qq(&samnale_width=120&samnale_height=120&compress_level=$compress_level);
	$line .= qq(&">);

	$line .= qq(
	<param name="animation_max" value="0"> 
	<param name="compress_level" value="$compress_level"> 
	<param name="dir_resource" value="$init{'skin_directory'}">);

$line .= qq(<param name="image_height" value="$image_height"> 
<param name="image_interlace" value="false">
<param name="image_jpeg" value="true">
<param name="image_size" value="$image_size">
<param name="image_width" value="$image_width">
<param name="layer_count" value="3">
<param name="poo" value="false">
<param name="quality" value="1">\n);

# お絵かき部分
if($main::in{'applet'} eq "pro"){ $line .= qq(<param name="res.zip" value="$init{'skin_directory'}res_pro.zip">\n); }
else{ $line .= qq(<param name="res.zip" value="$init{'skin_directory'}res_normal.zip">\n); }

$line .= qq(<param name="tt.zip" value="$init{'skin_directory'}tt.zip">\n);

$line .= qq(
<param name="security_click" value="0"> 
<param name="security_post" value="0">\n);

# Java による秒数制限
#$line .= qq(<param name="security_timer" value="$security_timer">);
#$line .= qq(<param name="security_url" value="${main::guide_url}%A4%AA%B3%A8%A4%AB%A4%AD%BB%FE%B4%D6%A5%A8%A5%E9%A1%BC">);

$line .= qq(<param name="send_advance" value="true">
<param name="send_header_count" value="true">
<param name="send_header_image_type" value="true">
<param name="send_header_timer" value="true">
<param name="send_language" value="sjis">
<param name="thumbnail_compress_level" value="15">
<param name="thumbnail_width" value="120">
<param name="thumbnail_height" value="120">\n);

# アニメオン/オフ
$line .= qq(<param name="thumbnail_type" value="animation">\n);
$line .= qq(<param name="thumbnail_type2" value="jpeg">\n);

# 使用ツール
if($main::in{'applet'} eq "pro"){ $line .= qq(<param name="tools" value="pro">\n); }
else{ $line .= qq(<param name="tools" value="normal">\n); }


$line .= qq(<param name="undo" value="100">
<param name="undo_in_mg" value="50"> 

<!--アプレット--> 
<param name="image_bkcolor" value="">	<!--キャンバスの背景色--> 
<param name="image_bk" value="">	<!--アプレットの背景のイメージ(タイル張り表示)--> 
<param name="color_text" value="#8099b3">	<!--アプレットのテキストカラー--> 
<param name="color_bk" value="#ffffff">	<!--アプレットの背景カラー--> 
<param name="color_bk2" value="#ccddee">	<!--アプレットの網状の線のカラー--> 
<!--アイコン--> 
<param name="color_icon" value="#eef3f9">	<!--アイコンのカラー--> 
<param name="color_frame" value="#ccddee">	<!--アイコンの枠のカラー--> 
<param name="color_iconselect" value="#ffccb3">	<!--アイコンを選択時出る枠のカラー--> 
<!--スクロールバー--> 
<param name="color_bar" value="#ccddee">	<!--バーのカラー--> 
<param name="color_bar_hl" value="#aaccee">	<!--バーのハイライトカラー --> 
<param name="color_bar_frame_hl" value="#ffffff">	<!--バーのフレームのハイライト--> 
<param name="bar_size" value="20">	<!--バーの太さ--> 
<!--ツールバー--> 
<param name="tool_color_button" value="#fffafa">	<!--ボタンの色上--> 
<param name="tool_color_button2" value="#fffafa">	<!--ボタンの色下--> 
<param name="tool_color_text" value="#806650">	<!--テキストの色--> 
<param name="tool_color_bar" value="#fffafa">	<!--変更バーの色--> 
<param name="tool_color_frame" value="#808080">	<!--枠の色--> 
</applet> 
<!--↑ここまでアプレット--> 
);

# 各種データ
$line .= qq(<div class="valaety_data">\n);

$line .= qq(<br$main::xclose>● お絵かきID： <span class="red">$image_session</span> （メモ必須）);
	if($image_title){ $line .= qq(<br$main::xclose>● タイトル： $image_title); }
	if($deny_sasikae_flag){ $line .= qq(<br$main::xclose>● 今後の差し替えを禁止します); }
	if($animation_flag){ $line .= qq(<br$main::xclose>● アニメーションを記録します); }
	if($continue_type eq "sasikae"){ $line .= qq(<br$main::xclose>● <a href="$image{'image_url_buffer'}" target="_blank" class="blank">$image{'session'}</a> の続きから描き、差し替えます); }
	elsif($continue_type eq "new"){ $line .= qq(<br$main::xclose>● <a href="$image{'image_url_buffer'}" target="_blank" class="blank">$image{'session'}</a> の続きから描き、新規投稿します); }
$line .= qq(<br$main::xclose>● キャンバスサイズ： 横${image_width} x 縦${image_height}\n);
if($main::myadmin_flag >= 5){ $line .= qq(<br$main::xclose>● スーパーID： $image{'super_id'}); }
$line .= qq(<br$main::xclose>●絵が出来たら左上の「投稿」を押してください。);

$line .= qq(</div>);

return($line);

}


#-----------------------------------------------------------
# 画像の削除（管理用）
#-----------------------------------------------------------
sub Image_delete{

my($type) = @_;

	# 権限エラー
	if(!$main::admin_mode){ main::error("削除できるのは管理者のみです。"); }

	# 画像データを取得
	my(%image) = Mebius::Paint::Image("Get-hash Justy",undef,undef,undef,$main::in{'realmoto'},$main::in{'postnumber'},$main::in{'resnumber'});

	# 画像を削除する
	if($main::in{'delete_type'} =~ /^(delete|penalty)$/){
		Mebius::Paint::Image("Delete-image Justy Renew-logfile-justy",undef,undef,undef,$main::in{'realmoto'},$main::in{'postnumber'},$main::in{'resnumber'});
	}

	# 画像を復活する
	elsif($main::in{'delete_type'} eq "revive"){
		Mebius::Paint::Image("Revive-image Justy Renew-logfile-justy",undef,undef,undef,$main::in{'realmoto'},$main::in{'postnumber'},$main::in{'resnumber'});
	}

	# モードエラー
	else{
		main::error("実行タイプを指定してください。");
	}

	# ペナルティを与える
	if($main::in{'delete_type'} eq "penalty"){
		my $penalty_url = "/_$main::in{'realmoto'}/$main::in{'postnumber'}.html#S$main::in{'resnumber'}" if($image{'main_type'});
		if($image{'host'}){ Mebius::penalty_file("Host Penalty Renew",$image{'host'},$image{'title'},"【画像の投稿】",$penalty_url); }
		if($image{'cnumber'}){ Mebius::penalty_file("Cnumber Penalty Renew",$image{'cnumber'},$image{'title'},"【画像の投稿】",$penalty_url); }
		if($image{'account'}){ Mebius::penalty_file("Account Penalty Renew",$image{'account'},$image{'title'},"【画像の投稿】",$penalty_url); }
	}

	# ペナルティを解除する
	if($main::in{'delete_type'} eq "revive"){
		if($image{'host'}){ Mebius::penalty_file("Host Repair Renew",$image{'host'}); }
		if($image{'cnumber'}){ Mebius::penalty_file("Cnumber Repair Renew",$image{'cnumber'}); }
		if($image{'account'}){ Mebius::penalty_file("Account Repair Renew",$image{'account'}); }
	}

	# リダイレクト
	if($main::in{'backurl'} && $main::backurl && $main::in{'allow_backurl'}){
		Mebius::Redirect(undef,$main::backurl);
	}
	else{
Mebius::Redirect(undef,"${main::main_url}?mode=pallet-viewer-$main::in{'realmoto'}-$main::in{'postnumber'}-$main::in{'resnumber'}$main::backurl_query_enc");
	}

}


#-----------------------------------------------------------
# 絵(Cookie)の削除
#-----------------------------------------------------------
sub List_delete{

# Cookieを削除
Mebius::Paint::Image("Get-cookie Delete-cookie-session",$main::in{'image_session'});

	# リダイレクト
	if(!$main::in{'redirected'}){
		Mebius::Redirect("","${main::main_url}?redirected=1&$main::postbuf");
	}

# リダイレクト跡は普通に確認ページを表示
&Before_page();

exit;

}

no strict;

#-----------------------------------------------------------
# 使っていないフォーム
#-----------------------------------------------------------

$form1 = qq(
<table class="qtable"><tr><td align="center" class="qtd"><p> 
<form name="paintform"> 
	<span title="キャンバスのサイズとクオリティ値、アプレットを変更します。

変になる場合は、サイズそのままでもう一度変更ボタンを押すと直ることが多いです"> 
	<small>Size</small> <input type="text" name="width" value="300" size=4>x<input type="text" name="height" value="300" size=4> 
	<small>Quality</small> 
<input type="hidden" name="quality" value=""> 
	<select name="kari"> 
		<option value="1">仮送信して描画を元に
		<option value="2">仮送信して画像を元に
		
	</select> 
	<select name="mode"> 
		<option value="paintbbs">PaintBBS</option> 
<option value="shipainter" selected>ShiPainter</option> 
<option value="shipainterpro">ShiPainter-Pro</option> 
 
	</select><br> 
	<input type="button" onClick="sizechange()" value="サイズ・クオリティ・アプレット変更"><br><br> 
	<small>※ →「画像を元に」の場合のみサイズも変えられます。(PNGの場合は環境に依存)<br> 
	(「PaintBBS」は「描画を元に」横サイズだけ変更できます)<br> 
	※ →「しぃペインター」間だけ描画を元にアプレットの変更ができます。<br> 
	
	※ → ここで、↑の「画像の保存フォーマット」の選択も有効になります。<br> 
	</small> 
</form> 
</p></td></tr></table> 

 
);

$form2 = qq(
<table><tr><td align="center"> 
	<table class="qtable"><tr><td align="center" class="qtd"><p> 
	<form action="" method="post"> 
	<input type="hidden" name="no" value=""> 
	<input type="hidden" name="mode" value="shipainter"> 
	<input type="hidden" name="type" value=""> 
	<input type="hidden" name="pass" value=""> 
	<input type="hidden" name="width" value="300"> 
	<input type="hidden" name="height" value="300"> 
	<input type="hidden" name="quality" value=""> 
	<input type="hidden" name="anime" value="1"> 
	<input type="hidden" name="painttime" value="1278320484"> 
	<span title="アンドゥの回数を変えます.">アンドゥ
	<input type="text" name="undo" value="100" size="3">回
	<input type="text" name="undo_in_mg" value="50" size="2">つに分けて
	<input type="submit" value="変更"> 
	</span> 
	</form> 
	</p></td></tr></table> 

	<table class="qtable"><tr><td align="center" class="qtd"><p> 
	<form action="" method="post"> 
	<input type="hidden" name="no" value="$main::in{'no'}"> 
	<input type="hidden" name="moto" value="$main::in{'moto'}">
	<input type="hidden" name="mode" value="pallet"> 
	<input type="text" name="image_width" value="$image_width"> 
	<input type="text" name="image_height" value="$image_height"> 
	<input type="submit" value="変更"> 
	</span> 
	</form> 
	</p></td></tr></table> 

);

$form3 = qq(
<table><tr><td align="center"> 
<input type="button" onClick="botusend()" value=" ボ ツ " title="画像だけ一時的に投稿し、保存することができます。ログには記録されません。"> 
 
</td></tr></table> 
);

}

#-----------------------------------------------------------
# 拡張パレット１
#-----------------------------------------------------------
sub Plus_pallet1{

# 宣言
my($line);

$line .= qq(
	<table class="ptable"><tr><td align=right class="ptd"><p> 
	<form name="nowpform"> 
	<span id="nowpl" title="今のカーソルの座標. 左が、右にセットした原点からの相対座標。右が今セットしてある原点の絶対座標. キャンバスの左上の座標を打ち込むといいかも。(手動；)">座標<br> 
	X<input type="text" name="nowpx" value="" size="3" title="今の X座標">+
	<input type="text" name="setpx" value="0" size="2" onblur="setposition()" title="原点(0,0)にする X座標. フォーカスアウトで固定"><br> 
	Y<input type="text" name="nowpy" value="" size="3" title="今の Y座標">+
	<input type="text" name="setpy" value="0" size="2" onblur="setposition()" title="原点(0,0)にする Y座標. フォーカスアウトで固定"><br> 
	</span> 
	</form> 
	</p></td></tr></table> 
 
<script language="javascript"><!--
	var d=document;
	if(d.layers){ d.captureEvents(Event.MOUSEMOVE); }
	d.onmousemove=nowposition;
//--></script> 
	<table class="ptable"><tr><td align=right class="ptd"> 
	<span title="アプレットフィット。

アプレットのサイズを画面のサイズに合わせます"> 
	App-Fit<br></span> 
	<input type="button" onClick="appletfit()" value="On"><br> 
	<input type="button" onClick="appletfit(1)" value="Off"></span><br> 
	</td></tr></table> 
	<table class="ptable"><tr><td align=right class="ptd"><p> 
	<form name="scalf"> 
	<span title="拡大・縮小"> 
	<sup>拡大/縮小</sup></span><br> 
	<input type="button" onClick="scale(1)" value="等倍" title="1倍に"><br> 
	<input type="button" onClick="scale(2)" value="２倍" title="2倍に"><br> 
	<input type="button" onClick="scale(3)" value="３倍" title="3倍に"><br> 
	<input type="button" onClick="scale(5)" value="５倍" title="5倍に"><br> 
	<input type="button" name="scalx" onClick="scale(0,2)" value="*2" title="今の2倍に拡大 (最大128倍)"><br> 
	<input type="button" name="scaly" onClick="scale(0,0,2)" value="*0.5" title="今の1/2倍に縮小 (切り上げ)"><br> 
	</form> 
	</p></td></tr></table> 
	<table class="ptable"><tr><td align=right class="ptd"><p> 
	<form name="layerform"> 
	<span title="レイヤーの追加と削除"> 
	レイヤー</span><br> 
	<span title="一番上にレイヤー追加"> 
	<input type="button" onClick="layeradd()" value="追加"></span><br> 
	<span title="一番上のレイヤーを削除。元に戻せないので注意。"> 
	<input type="button" onClick="layerdel()" value="削除"></span><br> 
	<span title="レイヤーを選択します">L-select<br> 
	<select name="layernum" size="4" onChange="layerselect(this.options[this.selectedIndex].value,this.options[this.selectedIndex].text)"> 
		<option value="2">layer2</option> 
		<option value="1">layer1</option> 
		<option value="0" selected>layer0</option> 
 
	</select><br> 
	</span> 
	<span title="書き直すと、選択中のレイヤーの名前を変更できます">レイヤー名<br> 
	<input type="text" name="layername" value="layer0" size=9 onblur="lnamechange()"><br> 
	</span> 
	</form> 
	</p></td></tr></table> 
 );

return($line);

}

#-----------------------------------------------------------
# 拡張パレット２
#-----------------------------------------------------------
sub Plus_pallet2{

# 宣言
my($line);

$line .= qq(

 
	<nobr> 
	<input type="button" onclick="pentool(0,0,255,0,-8,true,false)" value="鉛"> 
	<input type="button" onclick="pentool(3,2,180,12,-5,false,false)" value="水"> 
	<input type="button" onclick="pentool(2,2,64,12,-8,true,false)" value="空"> 
	<input type="button" onclick="pentool(1,0,120,0,-8,false,true)" value="ペ">&nbsp;
	<wbr> 
	<input type="button" onclick="hinttool(0)" value="手"> 
	<input type="button" onclick="hinttool(3)" value="■"></nobr><br> 
<script type="text/javascript"><!--
		palette_selfy();
	//--></script> 
</td> 
</tr></table> 
 
<table><tr><td align="center"> 
	<small>↓拡張ツールいろいろ. ボタンオンマウスでいろいろ説明がでます. 
	<br><br></small> 
</td></tr></table> 
<table class="qtable"><tr><td align="center" class="qtd"><p> 
<form name="glidform"> 
	<span title="ツール。"> 
		<input type="hidden" name="toolg" value="0"> 
	</span> 
	<span title="ラインを引く間隔。0ならなし。">間隔
		x<input type="text" name="widg" value="25" size="3"> 
		y<input type="text" name="heig" value="25" size="3"> 
	</span> 
	<span title="グリッドのときは傾き、集中線のときの中心座標を。

ちなみにキャンバスの中心が(x,y) = (0,0)です">傾き・中心
		x<input type="text" name="cenx" value="0" size="3"> 
		y<input type="text" name="ceny" value="0" size="3"> 
	</span> 
	<span title="ラインを引く間隔。0ならなし。">長さ
		<select name="leng"> 
			<option value="100">100%</option> 
			<option value="90">90%</option> 
			<option value="80">80%</option> 
			<option value="70">70%</option> 
			<option value="60">60%</option> 
			<option value="50">50%</option> 
			<option value="40">40%</option> 
			<option value="30">30%</option> 
			<option value="20">20%</option> 
			<option value="10">10%</option> 
			<option value="0">0%</option> 
			<option value="110">110%</option> 
			<option value="125">125%</option> 
			<option value="150">150%</option> 
			<option value="175">175%</option> 
			<option value="200">200%</option> 
			<option value="225">225%</option> 
			<option value="250">250%</option> 
		</select><br> 
	</span> 
	ランダム
	<span title="間隔をランダムにする。"> 
		<input type="checkbox" name="randg" value="1" class="ra">間隔
	</span> 
	<span title="間隔をランダムにする。"> 
		<input type="checkbox" name="randl" value="1" class="ra">長さ
	</span> 
	<span title="今のレイヤーにグリッドや集中線をひきます。

線や色、太さ、アルファ値などはパレットの状態で。

ペンは今のところできなかったのでできませんｗ"> 
		<input type="button" value="グリッドON" onClick="glidres(0)"> 
		<input type="button" value="集中線ON" onClick="glidres(1)"> 
	</span> 
</form> 
</p></td></tr></table> 


 );

return($line);

}
#-----------------------------------------------------------
# ヘッダのJavascript部分
#-----------------------------------------------------------
sub Head_javascript{

# 宣言
my(%init) = &Init();

$main::head_javascript .= qq(
<!--外部パレット--> 
<script type="text/javascript" src="$init{'skin_directory'}palette_selfy.js"></script>);

$main::head_javascript .= q(
<!--拡張ツール--> 
<script type="text/javascript"><!--
// Header
var phead = 'id=8uolW8Cu&pass=&name=&applet=shipainter&width=300&height=300&anime=1&pchsave=1&painttime=1278320484&ptimeoff=&quality=1&';
// 自分で送信ボタン
function resubmit(){
	document.paintbbs.pExit();
}
function hinttool(hi){
	document.paintbbs.getInfo().m.iHint = hi;
}
function pentool(p1,p2,p3,p4,p5,p6,p7){
	var dp=document.paintbbs;
	dp.getInfo().m.iPen = p1;
	dp.getInfo().m.iPenM = p2;
	dp.getInfo().m.iAlpha = p3;
//	dp.getInfo().m.iSize = p4;
	dp.getInfo().m.iCount = p5;
	dp.getInfo().m.isCount = p6;
	dp.getInfo().m.isAnti = p7;
}
// 今のポイント座標
var npx,npy; 
var setx=0; var sety=0;	// 初めの座標
function nowposition(e){
	var d=document;
	if(d.layers){
		npx=e.pageX;  npy=e.pageY;
	}else if((d.getElementById) && (!d.all)){
		npx=e.pageX;  npy=e.pageY;
	}else if(d.all){
		npx=d.body.scrollLeft+event.clientX;
		npy=d.body.scrollTop+event.clientY;
	}
	d.forms.nowpform.nowpx.value = npx - setx;
	d.forms.nowpform.nowpy.value = npy - sety;
}
// ポジションをセット
function setposition(e){
	var d=document;
/*
	if(d.layers){
		setx=e.pageX;  sety=e.pageY;
	}else if((d.getElementById) && (!d.all)){
		setx=e.pageX;  sety=e.pageY;
	}else if(d.all){
		setx=d.body.scrollLeft+event.clientX;
		sety=d.body.scrollTop+event.clientY;
	}
*/
	setx = Number(d.forms.nowpform.setpx.value.replace(/[^0-9]/g,''));
	if(!setx){ setx=0; }
	d.forms.nowpform.setpx.value = setx;
	sety = Number(d.forms.nowpform.setpy.value.replace(/[^0-9]/g,''));
	if(!sety){ sety=0; }
	d.forms.nowpform.setpy.value = sety;
}
// アプレットフィット
function appletfit(f){
	var d=document;
	if(!d.all){ return; }
	if(f != 1){
		var cwid = d.body.clientWidth - 260;
		var chei = d.body.clientHeight - 105;
		if(cwid > d.paintbbs.width) { d.paintbbs.width  = cwid; }
		if(chei > d.paintbbs.height){ d.paintbbs.height = chei; }
	}else if("490" && "450"){
		d.paintbbs.width  = "490";
		d.paintbbs.height = "450";
	}
}

// 拡大縮小
var nowsc=1;
function scale(sc,xx,yy){
	var d=document;
	if(sc == 0.5 || (nowsc<=1 && yy==2)){
		if(nowsc > 1){ d.paintbbs.getMi().scaleChange(1,true); }
		sc=-1;
		d.paintbbs.getMi().scaleChange(sc,false);
		nowsc=0.5;
		if(d.forms.scalf){
			d.forms.scalf.scalx.value = '*'+1;
			d.forms.scalf.scaly.value = '*'+0.5;
		}
	}else{
		if(!sc){ sc=nowsc; }
		if(xx){ sc=nowsc*xx; }
		else if(yy){ sc = Math.floor((nowsc+1)/yy); }
		if(sc < 1){ sc = 1; }else if(sc > 128){ sc = 128; }
		d.paintbbs.getMi().scaleChange(sc,true);
		nowsc=sc;
		var nowsy = 0.5;
		if(nowsc != 1){ nowsy = Math.floor((nowsc+1)/2); }
		if(d.forms.scalf){
			d.forms.scalf.scalx.value = '*'+(nowsc*2);
			d.forms.scalf.scaly.value = '*'+nowsy;
		}
	}
}
// 座標とか
var digit=new Array("0","1","2","3","4","5","6","7","8","9","a","b","c","d","e","f");
function getByte(value){
 return digit[(value>>>4)&0xf]+digit[value&0xf];
}
function getShort(value){
 return getByte(value>>>8)+getByte(value&0xff);
}
function getInt(value){
 return getShort(value>>>16)+getShort(value&0xffff);
}
// レイヤー
var len,la,ln,optionlength;
var lname = new Array();
// レイヤー追加
function layeradd(){
	var dl=document.forms.layerform.layernum;
	len=eval(Number(document.paintbbs.getLSize()));	// レイヤーの数
	document.paintbbs.send("iHint=14@"+getInt(1)+getInt(len+1),false);	//同期
	len++;
	newselect(len);
	dl.options[0].selected = true;
	layerselect(dl.options[0].value,dl.options[0].text)
}
// レイヤー削除
function layerdel(){
	var ok = confirm("リストの中で、一番上のレイヤーを削除します。\n（いま選択しているレイヤーではありません！）\n一度レイヤーを削除すると、元には戻せません。\nそれでもよろしいですか？");
	if(ok){
		var dl=document.forms.layerform.layernum;
		len=eval(Number(document.paintbbs.getLSize()));	// レイヤーの数
		if(len<=1){ return; }
		document.paintbbs.send("iHint=14@"+getInt(1)+getInt(len-1),false);	//同期
		len--;
		lname[len]='';
		dl.options[len] = null;
		newselect(len);
		dl.options[0].selected = true;
		layerselect(dl.options[0].value,dl.options[0].text)
	}
}
// レイヤーセレクトの増減
function newselect(lg,v) {
	var dl=document.forms.layerform.layernum;
	if(!lg){ lg=eval(Number(document.paintbbs.getLSize())); }	// レイヤーの数
	var lo = dl.options.length;
	if(lg != lo){
		while(dl.options.length>lg){
			dl.options[0]=null; lname[dl.options.length]=''; }
		while(dl.options.length<lg){
			dl.options[dl.options.length]=new Option('--',dl.options.length); }
		for(var l=0;l<lg;l++){
			var la = lg-l-1;
			if(lname[la]){ ln = lname[la]; }else{ ln = 'layer'+la; }
			dl.options[l].value = la;
			dl.options[l].text  = ln;
		}
		if(v){ dl.options[(lg-v-1)].selected = true; }	// select
	}
}
// レイヤーセレクト
function layerselect(v,n) {
	document.paintbbs.getInfo().m.iLayer = v;	// 選択するレイヤー番号
	document.forms.layerform.layername.value = n;
	newselect('',v);
}
// レイヤー名変更
function lnamechange(){
	var dl=document.forms.layerform;
	ln = dl.layernum.options[dl.layernum.selectedIndex];
	ln.text = dl.layername.value;
	lname[ln.value] = dl.layername.value;
}
var header,xy,cls,dfg,wids,heis,katax,katay,longx,longy,rands,randt,i,j,tls,siz,lens,alp,lyr,pen,pem,cnt,qual,gwid,ghei;
// グリッドフォームの内容うけとり
function glidres(g){
	qual = 1;
	gwid = 300*qual;
	ghei = 300*qual;
	var dp=document.paintbbs;
	// アプレットから
	// getcolorz = String(dp.getColors()).split("\\n");
	// cls = Number(getcolorz[0].replace(/\#/,"0x"));
	cls = dp.getInfo().m.iColor;
	alp = dp.getInfo().m.iAlpha;
	siz = dp.getInfo().m.iSize;
	pen = dp.getInfo().m.iPen;
	pem = dp.getInfo().m.iPenM;
	ant = dp.getInfo().m.isAnti;
	cnt = dp.getInfo().m.isCount;
	lyr = dp.getInfo().m.iLayer;
 
	// フォームから
	dfg = document.forms.glidform;
	wids = Number(dfg.widg.value)*qual;
	heis = Number(dfg.heig.value)*qual;
	katax = Number(dfg.cenx.value)*qual;
	katay = Number(dfg.ceny.value)*qual;
 
	lens = Number(dfg.leng.value);
	tls  = Number(dfg.toolg.value);
	if(dfg.randg.checked){ rands = 1; }else{ rands = 0; }
	if(dfg.randl.checked){ randt = 1; }else{ randt = 0; }
 
	// header
	header  = 'iHint='+tls+';iPen='+pen+';PenM='+pem+';iColor='+cls+';iSize='+siz;
//	header += ';isCount='+cnt+';isAnti='+ant;
	header += ';iAlpha='+alp+';iLayer='+lyr+'@';
 
	// 行き先
	if(g==1){ syutyu(); }
	else{ glid(); }
}
// グリッドをひく
function glid(){
	if(xy==1){
		if(heis){ glidhei(); }
		if(wids){ glidwid(); }
		xy=0;
	}else{
		if(wids){ glidwid(); }
		if(heis){ glidhei(); }
		xy=1;
	}
}
// グリッド 横
function glidwid(){
	if(xy==1){
		i=gwid*2;
		wids *= -1;
	}else{
		i=-gwid;
	}
	while((xy!=1 && i<=gwid*2) || (xy==1 && i>=-gwid)){
		if(rands!=1){
			i+=wids;
		}else{
			i = i + Math.floor(Math.random()*wids*2);
		}
		if((xy!=1 && i<=gwid*2) || (xy==1 && i>=-gwid)){  }else{ break; }
		toxi = Math.floor((katax)*lens/100);
		toyi = Math.floor(ghei*lens/100);
		if(randt==1){
			rany = Math.random();
			toxi = Math.floor(toxi*rany);
			toyi = Math.floor(toyi*rany);
		}
		document.paintbbs.send(header + getShort(i)+getShort(0) + getByte(128)+getShort(toxi) + getByte(128)+getShort(toyi),true);
	}
}
// グリッド 縦
function glidhei(){
	if(xy==1){
		i=ghei*2;
		heis *= -1;
	}else{
		i=-ghei;
	}
	while((xy!=1 && i<=ghei*2) || (xy==1 && i>=-ghei)){
		if(rands!=1){
			i+=heis;
		}else{
			i = i + Math.floor(Math.random()*heis*2);
		}
		if((xy!=1 && i<=ghei*2) || (xy==1 && i>=-ghei)){  }else{ break; }
		toxi = Math.floor(gwid*lens/100);
		toyi = Math.floor(katay*lens/100);
		if(randt==1){
			rany = Math.random();
			toxi = Math.floor(toxi*rany);
			toyi = Math.floor(toyi*rany);
		}
		document.paintbbs.send(header + getShort(0)+getShort(i) + getByte(128)+getShort(toxi) + getByte(128)+getShort(toyi),true);
	}
}
 
 
// 集中線をひく
function syutyu(){
	longx = Math.abs(katax) + Math.floor(gwid/2);
	longy = Math.abs(katay) + Math.floor(ghei/2);
	katax += Math.floor(gwid/2);
	katay += Math.floor(ghei/2);
 
	// ドット
	if(lens == 100 && randt != 1){
		document.paintbbs.send(header + getShort(katax)+getShort(katay) + "0100",true);
	}
	if(xy==1){
		if(heis){ linehei(); }
		if(wids){ linewid(); }
		xy=0;
	}else{
		if(wids){ linewid(); }
		if(heis){ linehei(); }
		xy=1;
	}
}
// 集中線 横
function linewid(){
	var a=1; var b=1;
	if(xy==1){
		i=gwid;
		wids *= -1;
	}else{
		i=0;
	}
	j=i;
	while((xy!=1 && i<=gwid) || (xy==1 && i>=0)){
		if(rands==1){	// random up
			j = i + Math.floor(Math.random()*wids*2);
			i = i + Math.floor(Math.random()*wids*2);
			if((xy!=1 && i<=gwid) || (xy==1 && i>=0)){  }else{ break; }
		}
		if(lens != 100){
			a = 1 - (longy*(1-lens/100)) / Math.sqrt((katax-i)*(katax-i)+(ghei-katay)*(ghei-katay));
			b = 1 - (longy*(1-lens/100)) / Math.sqrt((katax-j)*(katax-j)+katay*katay);
		}
		toxi = Math.floor((katax-i)*a);
		toyi = - Math.floor((ghei-katay)*a);
		toxj = Math.floor((katax-j)*b);
		toyj = Math.floor((katay)*b);
		if(randt==1){
			rany = Math.random();
			toxi = Math.floor(toxi*rany);
			toyi = Math.floor(toyi*rany);
			rany = Math.random();
			toxj = Math.floor(toxj*rany);
			toyj = Math.floor(toyj*rany);
		}
		document.paintbbs.send(header + getShort(i)+getShort(ghei) + getByte(128)+getShort(toxi) + getByte(128)+getShort(toyi),true);
		document.paintbbs.send(header + getShort(j)+getShort(0) + getByte(128)+getShort(toxj) + getByte(128)+getShort(toyj),true);
		if(rands!=1){	// normal up
			i+=wids;
			j=i;
		}
	}
}
// 集中線 縦
function linehei(){
	var a=1; var b=1;
	if(xy==1){
		i=ghei;
		heis *= -1;
	}else{
		i=0;
	}
	j=i;
	while((xy!=1 && i<=ghei) || (xy==1 && i>=0)){
		if(rands==1){	// random up
			j = i + Math.floor(Math.random()*heis*2);
			i = i + Math.floor(Math.random()*heis*2);
			if((xy!=1 && i<=ghei) || (xy==1 && i>=0)){  }else{ break; }
		}
		if(lens != 100){
			a = 1 - (longx*(1-lens/100)) / Math.sqrt((gwid-katax)*(gwid-katax)+(katay-i)*(katay-i));
			b = 1 - (longx*(1-lens/100)) / Math.sqrt(katax*katax+(katay-j)*(katay-j));
		}
		toxi = - Math.floor((gwid-katax)*a);
		toyi = Math.floor((katay-i)*a);
		toxj = Math.floor((katax)*b);
		toyj = Math.floor((katay-j)*b);
		if(randt==1){
			rany = Math.random();
			toxi = Math.floor(toxi*rany);
			toyi = Math.floor(toyi*rany);
			rany = Math.random();
			toxj = Math.floor(toxj*rany);
			toyj = Math.floor(toyj*rany);
		}
		document.paintbbs.send(header + getShort(gwid)+getShort(i) + getByte(128)+getShort(toxi) + getByte(128)+getShort(toyi),true);
		document.paintbbs.send(header + getShort(0)+getShort(j) + getByte(128)+getShort(toxj) + getByte(128)+getShort(toyj),true);
		if(rands!=1){	// normal up
			i+=heis;
			j=i;
		}
	}
}
// 没投稿
function botusend(){
	var okb = confirm("ボツ状態で投稿します。\n画像等をサーバ上に一時的に保存しますが、\nログデータには記録されません。\n\n投稿後は投稿者だけ見ることができる画面にいきます。\nそこでイメージを保存したら\n「削除する」か「やっぱり投稿する」か選んで、片付けてください。\nよろしいですか？");
	if(okb){
		document.paintbbs.str_header = phead + 'loot=botusent&nosave=1&';
		resubmit();
	}
}
// サイズチェンジ
function sizechange(){
	var m='';
	var w='';
	var h='';
	var a='';
	var qu='';
	var fm='';
	var is='';
	var dpf='';
	var k='';
	var stri='';
	var ok='';
	var djf='1';
	dpf = document.forms.paintform;
	if(dpf.width && dpf.width.value){ w = dpf.width.value; }	// width
	if(dpf.height && dpf.height.value){ h = dpf.height.value; }	// height
	if(dpf.quality && dpf.quality.value){ qu = dpf.quality.value; }	// quality
	if(dpf.mode && dpf.mode.value){ m = dpf.mode.value; }
	else{ m = "shipainter"; }
	if(djf && document.forms.jpngform){
		var djf = document.forms.jpngform;
		if(djf.image_format[0] && djf.image_format[0].checked == true){ fm = 'png';}
		else if(djf.image_format[1] && djf.image_format[1].checked == true){ fm = 'jpg';}
		else if(djf.image_size){ fm = 'each'; is = djf.image_size.value; }
	}
	stri  = 'mode='+m+'&no=&value4=shipainter&nosave=1&value3='+h+'&value2='+w;
	stri += '&value5='+qu+'&value6='+fm+'&value7='+is+'&';	// string
 
	if(dpf.kari){
		if(dpf.kari.value==1){	// anime
			document.paintbbs.str_header = phead + 'loot=sizechanged&value=1&'+stri;
			resubmit();
		}else if(dpf.kari.value==2){	// picture
			var ok = confirm("画像を元に、で画像がPNGで保存される場合は、\n環境によっては続きからは描けないことがあります。\nWin+IEはほぼ×(できる場合も)、MacやNNなら○？\nよろしいですか？");
			if(ok){
				document.paintbbs.str_header = phead + 'loot=sizechanged&value=2&'+stri;
				resubmit();
			}
		}else{	// paintBBS
			location.href='paint.cgi?'+'mode=shipainter&no=&width=300&height='+h+'&anime=1';
		}
	}else{ alert('forms.paintform.kari がみつかりません'); }
}
 
//--></script> 
 
);

}

#----------------------#
#  アニメーション表示  #
#----------------------#
sub Viewer{

# 宣言
my(%thread,$animation_applet,$print);

# ログデータから各種データを取得
my(%image) = Mebius::Paint::Image("Get-hash Justy",undef,undef,undef,$main::submode3,$main::submode4,$main::submode5);

# タイトル定義
if($image{'title'}){ $main::head_link3 = qq(&gt; $image{'title'}); }

# CSS定義
$main::css_text .= qq(
.body1{text-align:center;}
div.image_comment{text-align:left;padding:1em;margin:1em auto;background:#eee;width:$image{'width'}px;}
strong.image_title{font-size:140%;}
div.ads1{margin:2em 0em;}
form{margin:1em 0em;}
);

	# データからタイトルを定義
	if($image{'title'}){
			if($main::submode2 eq "animation"){ $main::sub_title = qq(”$image{'title'}”のアニメーション | メビお絵かき);  }
			else{ $main::sub_title = qq($image{'title'} | メビお絵かき); }
	}

# 削除済みの場合
if($image{'deleted'} && !$main::admin_mode){ main::error("この画像は削除済みです。 削除者： $image{'delete_person'} 削除日時： $image{'delete_date'}","410 Gone"); }

# ファイルの有無をチェック
if(!$image{'image_ok'} && !$main::admin_mode){ main::error("データが存在しません。"); }

	# アニメーション用のアプレットを取得
	if($main::submode2 eq "animation"){
		($animation_applet) = &Animation_applet("",%image);
	}


# 絵のタイトル
if($image{'title'}){ $print .= qq(<strong class="image_title">$image{'title'}</strong>); }

	# 画像が削除済みの場合
	if($image{'deleted'}){
		$print .= qq(<br$main::xclose><br$main::xclose>);
		$print .= qq(<span class="red">★削除済み画像です。管理者にだけ表\示しています。削除者： $image{'delete_person'} 削除日時： $image{'delete_date'}</span><br$main::xclose><br$main::xclose> <img src="$image{'image_url_deleted'}" alt="お絵かき画像" style="width:$image{'width'};height:$image{'height'};" alt="一時保存された絵"><br$main::xclose><br$main::xclose>);
	}

	# 画像部分
	else{
		$print .= qq(<br$main::xclose><br$main::xclose>);
		$print .= qq(<img src="$image{'image_url'}" alt="お絵かき画像" style="width:$image{'width'};height:$image{'height'};" alt="一時保存された絵"><br$main::xclose><br$main::xclose>);
	}

	# アニメーション部分
	if($image{'key'} =~ /Animation/ && $main::submode2 eq "viewer"){
			if($main::admin_mode){
				$print .= qq([ <a href="$main::script?mode=pallet-animation-$main::submode3-$main::submode4-$main::submode5#ANIMATION">アニメーション</a> ]);
			}
			else{
				$print .= qq([ <a href="./pallet-animation-$main::submode3-$main::submode4-$main::submode5.html#ANIMATION">アニメーション</a> ]);
			}
		$print .= qq(<br$main::xclose><br$main::xclose>\n);
	}

$print .= qq(<div class="image_data medium_height">);

	# 作者名
	if($image{'handle'}){
		$print .= qq( 作者： );
		$print .= qq($image{'handle'});
			if($image{'trip'}){ $print .= qq(☆$image{'trip'}); }
		$print .= qq(<br$main::xclose>);
	}


	# 各種データ
	if($image{'steps'}){ $print .= qq(　ステップ数： $image{'all_steps'}); }
	if($main::myadmin_flag >= 5){ $print .= qq( / $image{'steps'} ); }
	if($image{'all_painttime'}){
		my($all_paint_time) = Mebius::SplitTime(undef,$image{'all_painttime'});
		$print .= qq(　描画時間： $all_paint_time);
	}
	if($image{'thread_url'}){
		(%thread) = Mebius::BBS::thread({},$image{'realmoto'},$image{'postnumber'});
			if($image{'realmoto'} !~ /^sc/){
				$print .= qq(　 元記事： <a href="$image{'thread_url'}">$thread{'subject'}</a>);
			}
	}
	if($image{'res_url'}){
			if($image{'realmoto'} !~ /^sc/){
		$print .= qq( ( <a href="$image{'res_url'}">レス</a> ));
			}
	}

$print .= qq(</div>);

# 画像の説明文
if($image{'comment'}){ $print .= qq(<div class="image_comment">$image{'comment'}</div>); }

	# 削除フォーム
	if($main::admin_mode){

		$print .= qq(<form action="${main::main_url}"><div>\n);
		
			# 削除済みの場合
			if($image{'deleted'}){
				$print .= qq(<input type="radio" name="delete_type" value="revive" id="image_revive">);
				$print .= qq( <label for="image_revive"><span class="blue">画像を復活</span></label>\n);
			}

			# 未削除の場合
			else{
				$print .= qq(<input type="radio" name="delete_type" value="delete" id="image_delete">);
				$print .= qq( <label for="image_delete">画像を削除</label>\n);
				$print .= qq(<input type="radio" name="delete_type" value="penalty" id="image_penalty">);
				$print .= qq( <label for="image_penalty"><span class="red">画像を削除(ペナルティ)</span></label>\n);
			}

		$print .= qq(<input type="hidden" name="mode" value="pallet">\n);
		$print .= qq(<input type="hidden" name="type" value="image_delete">\n);
		$print .= qq(<input type="hidden" name="realmoto" value="$image{'realmoto'}">\n);
		$print .= qq(<input type="hidden" name="postnumber" value="$image{'postnumber'}">\n);
		$print .= qq(<input type="hidden" name="resnumber" value="$image{'resnumber'}">\n);
			if($main::in{'backurl'} && $main::backurl){
				 $print .= qq($main::backurl_input\n);
				$print .= qq(<input type="submit" name="allow_backurl" value="実行する(戻)" class="back">\n);
			}
		$print .= qq(<input type="submit" value="実行する">\n);
		$print .= qq(</div></form>\n);
	}


# 広告
my $ads = qq(
<div class="ads1">
<script type="text/javascript"><!--
google_ad_client = "pub-7808967024392082";
/* 記事データ */
google_ad_slot = "9966248153";
google_ad_width = 728;
google_ad_height = 90;
//-->
</script>
<script type="text/javascript"
src="http://pagead2.googlesyndication.com/pagead/show_ads.js">
</script>
</div>
);

	if(!$main::admin_mode){ $print .= qq($ads); }


$print .= qq($animation_applet);


Mebius::Template::gzip_and_print_all({},$print);


exit;


}


#-----------------------------------------------------------
# アニメーション表示のためのアプレットを定義
#-----------------------------------------------------------
sub Animation_applet{

# 局所化
my($type,%image) = @_;
my(%init) = &Init();
my($line,$applet_width,$applet_height);

	# リターンする場合
	if(!-f $image{'animation_file'}){ return(); }
	if(!$main::admin_mode && $image{'key'} !~ /Animation/){ return(); }

# アプレットのサイズ
$applet_width = $image{'width'};
$applet_height = $image{'height'} + 26;

#<param name="pch_file" value="$image{'animation_url'}">

# HTML部分
$line .= qq(
<div class="animation" id="ANIMATION">
アニメーション：<br$main::xclose><br$main::xclose>

<!--↓ここからアプレット--> 
<applet mayscript code="pch2.PCHViewer.class" archive="$init{'skin_directory'}PCHViewer.jar" name="pchapp" width="$applet_width" height="$applet_height"> 
<param name="pch_file" value="$image{'animation_url'}">

<param name="buffer_canvas" value="false">
<param name="buffer_progress" value="false">
<param name="dir_resource" value="$init{'skin_directory'}">
<param name="image_height" value="$image{'width'}">
<param name="image_width" value="$image{'height'}">

<param name="progress" value="true">
<param name="res.zip" value="$init{'skin_directory'}res_normal.zip">
<param name="run" value="true">
<param name="speed" value="0">
<param name="tt.zip" value="$init{'skin_directory'}tt.zip">

 	<!--APPLET_STYLE_PARAM--> 
 
	<!--アプレット--> 
	<param name="image_bkcolor" value="">	<!--キャンバスの背景色--> 
	<param name="image_bk" value="">	<!--アプレットの背景のイメージ(タイル張り表示)--> 
	<param name="color_text" value="#8099b3">	<!--アプレットのテキストカラー--> 
	<param name="color_bk" value="#ffffff">	<!--アプレットの背景カラー--> 
	<param name="color_bk2" value="#ccddee">	<!--アプレットの網状の線のカラー--> 
	<!--アイコン--> 
	<param name="color_icon" value="#eef3f9">	<!--アイコンのカラー--> 
	<param name="color_frame" value="#ccddee">	<!--アイコンの枠のカラー--> 
	<param name="color_iconselect" value="#ffccb3">	<!--アイコンを選択時出る枠のカラー--> 
	<!--スクロールバー--> 
	<param name="color_bar" value="#ccddee">	<!--バーのカラー--> 
	<param name="color_bar_hl" value="#aaccee">	<!--バーのハイライトカラー --> 
	<param name="color_bar_frame_hl" value="#ffffff">	<!--バーのフレームのハイライト--> 
	<param name="bar_size" value="20">	<!--バーの太さ--> 
	<!--ツールバー--> 
	<param name="tool_color_button" value="#fffafa">	<!--ボタンの色上--> 
	<param name="tool_color_button2" value="#fffafa">	<!--ボタンの色下--> 
	<param name="tool_color_text" value="#806650">	<!--テキストの色--> 
	<param name="tool_color_bar" value="#fffafa">	<!--変更バーの色--> 
	<param name="tool_color_frame" value="#808080">	<!--枠の色--> 
	<!--/APPLET_STYLE_PARAM--> 
</applet> 
</div>
<br$main::xclose>
<br$main::xclose>
);

# 使っていないコントロールパネル

my $applet_control = qq(
<table style="margin:auto;"><tr><td align="center"> 
	<small><br> 
	<span title="数字が小さくなるほど早い。"> 
	再生速度 : </span> 
	<input type="text" id="speedy" name="speed" value="0" size=3 
		style="text-align:center" onblur="playspeed(0,this.value)"> 
	<input type="button" value="△" title="スピードUP" onClick="playspeed(1)"> 
	<input type="button" value="▽" title="スピードDOWN" onClick="playspeed()"> 
	</small><br> 
	<small> 
	レイヤー数 : 
	<font title="layer_count">3</font> 
	/ 
	<font title="layer_max"></font> 
	/ 
	<font title="layer_last"></font> 
	,
	クオリティ値 : 
	<font title="クオリティ値">1</font> 
	<br> 
	サイズ : 
	<font title="幅">$image{'width'}</font> 
	x
	<font title="高さ">$image{'height'}</font> 
	px /
	<font title="アニメーションファイルの大きさ">? kb</font> 
	</small> 
</td></tr></table> 
);

return($line);

}


1;
