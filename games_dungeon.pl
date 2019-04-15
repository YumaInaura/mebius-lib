
package Mebius::Dungeon;
use strict;

#-----------------------------------------------------------
# 基本設定を取り込み
#-----------------------------------------------------------
sub Init{

# 宣言
my($dungeon_url);

# CSS定義
$main::css_text .= qq(
.body1{background:#000;color:#fff;padding:1.5em;}
div.actions{word-spacing:0.3em;}
div.navilinks{margin:1em 0em;}
ul{margin:0.5em 0em;}
);

	# 基本ＵＲＬ
	if($main::kflag){
		$dungeon_url = qq(http://$main::server_domain/imode/_games/dungeon/);
	}
	else{
		$dungeon_url = qq(http://$main::server_domain/_games/dungeon/);
	}

# 設定値を渡す
return(
"basemode" => "",
"title" => "ダンジョンワーク",
"dungeon_url" => "$dungeon_url",
"white_style" => qq( style="color:#fff;"),
"levy_blankhour" => 1
);

}

#-----------------------------------------------------------
# ゲームモード振り分け
#-----------------------------------------------------------
sub Mode{

# 宣言
my(%init) = &Init();

	# 基本タイトルを定義
	$main::head_link3 = qq( &gt; <a href="./"$main::sikibetu>$init{'title'}</a> );
	$main::sub_title = $init{'title'};

	# グローバル変数を初期化
	our(%done) = undef;

	# メインパッケージのグローバル変数を定義	
	$main::kboad_link_select = qq( <a href="./" accesskey="3"$main::sikibetu>③ﾒﾆｭｰ</a>);
	$main::kboad_link_select2 = qq( ③ﾒﾆｭｰ);

	# モード振り分け
	if($main::mode eq ""){ &Index("Pure-index"); }
	elsif($main::submode1 eq "status"){ &Status("Page-view Detail Select",$main::submode2); }
	elsif($main::submode1 eq "member"){ &Member("Page-view Index"); }
	elsif($main::mode eq "aube"){ &Aube("Page-view"); }
	elsif($main::mode eq "go"){ &Go("",$main::in{'select'}); }
	elsif($main::mode eq "newstart"){ &Newstart(); }
	else{ main::error("ページが存在しません。"); }

}


#-----------------------------------------------------------
# ダンジョントップページ ( 無限ループに注意！ )
#-----------------------------------------------------------
sub Index{

# 基本設定を取得
my($type,$h1,$message) = @_;
my(%init) = &Init();
my($status_line,%status,$newstart_line,$action_line,$navilinks_line,$otherlinks_line);
our(%done);

	# 無限ループを回避
	if($done{'index'}){ return(); }
	$done{'index'} = 1;

	# メインパッケージのグローバル変数を定義	
	$main::kboad_link_select = qq( ③ﾒﾆｭｰ);
	$main::kboad_link_select2 = qq( ③ﾒﾆｭｰ);

	# ヘッダリンクを定義
	if($type =~ /Pure-index/){
		$main::head_link3 = qq( &gt; $init{'title'} );
		$main::sub_title = $init{'title'};
	}

	# ステータス
	if($type !~ /Only-view/){ ($status_line,%status) = &Status("Me"); }

	# 新規登録フォーム
	if($type !~ /Only-view/){
			if($status{'key'} eq "1"){ }
			else{
				$newstart_line = qq(
				$main::khrtag<h2$main::kfontsize_h2>新規登録</h2>
				<form action="./" method="post"$main::sikibetu>
				<div>
				<input type="hidden" name="moto" value="games"$main::xclose>
				<input type="hidden" name="game" value="dungeon"$main::xclose>
				<input type="hidden" name="mode" value="newstart"$main::xclose>
				<input type="submit" value="新規登録する"$main::xclose>
				$main::kinputtag
				</div>
				</form>
				);
			}
	}

	# 行動フォームを取得
	if($type !~ /Only-view/){ ($action_line) = &Form("Action",%status); }

	# H1を定義
	if($h1){
		$main::sub_title = qq($h1 | $init{'title'});
		$main::head_link4 = qq( &gt; $h1);
		$h1 = qq(<h1$main::kfontsize_h1>$h1</h1>);
	}
	else{
		$h1 = qq(<h1$main::kfontsize_h1>$init{'title'}</h1>);
	}

	# メッセージを定義
	if($message){ $message = qq($message);}
	else{ 
		$message = qq(
		このゲームはテスト中です。<strong class="red">本当に、予\告なしに</strong>、すべてのゲームデータは削除される場合があります。
		);
	}
	if($type =~ /Link-to-back/){ $message .= qq(<a href="$init{'dungeon_url'}"$init{'white_style'}$main::sikibetu>戻る</a>); }

	# ナビゲーションリンクを定義
	if($type =~ /Navi-links/){ 
		$navilinks_line .= qq(<a href="./"$init{'white_style'}$main::sikibetu>メニューに戻る</a>\n);
	}
	if($type =~ /Status-view/){
		$navilinks_line .= qq(<a href="./member"$init{'white_style'}$main::sikibetu>参加者</a>\n);
	}
	if($navilinks_line){ $navilinks_line = qq(<div class="navilinks">$navilinks_line</div>); } 

	# その他のリンク ( ログインしていなくても表示する )
	if($type !~ /Only-view/){
		$otherlinks_line .= qq($main::khrtag<h2$main::kfontsize_h2>一覧</h2>);
		$otherlinks_line .= qq(<a href="./member"$init{'white_style'}$main::sikibetu>参加者</a>);
	}


# ヘッダ
main::header("Body-print Not-search-me Mobile-background-black Not-hr");

# HTML
print qq(
$h1
$navilinks_line
<div class="message">$message</div>
$newstart_line
<div class="actions">$action_line</div>
$status_line
$otherlinks_line
);

# フッタ
main::footer("Body-print Not-hr");

exit;


}

#-----------------------------------------------------------
# 行動フォームを取得
#-----------------------------------------------------------
sub Form{

# 宣言
my($type) = @_;
my(%init) = &Init();
my($line,$monster_link,$levy_link,$fight_link);

	# マイデータを取得
	my(%status) = &Datafile("Me Get");

	# マイデータがない場合リターンする
	if($status{'key'} ne "1"){ return(); }

# 整形
$line .= qq($main::khrtag<h2$main::kfontsize_h2>行動</h2>\n);

	# ダウンしている場合
	if($status{'down_flag'}){ $line .= qq($status{'down_flag'}); }

	else{

		# ”魔物を増やす”リンク
		($monster_link) = &Buy("Get-link",undef,%status);
		$line .= $monster_link;

		# ”税金を徴収”リンク
		($levy_link) = &Levy("Get-link",undef,%status);
		$line .= $levy_link;

		# ”敵を迎え討つ”リンク
		($fight_link) = &Fight("Get-link",undef,%status);
		$line .= $fight_link;

	}

# 整形
$line .= qq($main::khrtag<h2$main::kfontsize_h2>その他</h2>\n);

	# ”オーブ”リンク
	if($status{'aube'} eq ""){}
	else{ $line .= qq(<a href="./aube"$init{'white_style'}$main::sikibetu>オーブ($status{'aube'})</a>); }

# リターン
return($line);

}

#-----------------------------------------------------------
# 行動する（全般）
#-----------------------------------------------------------
sub Go{

# 宣言
my($type,$select) = @_;
my(%init) = &Init();
my(%renew,%status,$status_line,$message,$action_line,$message2,$h1,$this_title);

# データを取得
(%status) = &Datafile("Me Get Action");

	# ダウンしている場合
	if($status{'down_flag'}){ main::error("$status{'down_flag'}"); }

	# キーが無い場合
	if($status{'key'} eq ""){ Mebius::Redirect("",$init{'dungeon_url'}); }

	# タイプ振り分け
	if($main::in{'type'} eq "buy"){
		($message,$this_title,%status) = &Buy("Buy",undef,%status);
	}
	elsif($main::in{'type'} eq "fight"){
		($message,$this_title,%status) = &Fight("",undef,%status);
	}
	elsif($main::in{'type'} eq "levy"){
		($message,$this_title,%status) = &Levy("",undef,%status);
	}
	elsif($main::in{'type'} eq "aube"){
		($message,$this_title,%status) = &Aube("Use",$main::in{'select'},%status);
	}
	elsif($main::in{'type'} eq "edit"){
		($message,$this_title,%status) = &Edit("Edit",undef,%status);
	}
	else{
		main::error("行動タイプを選んでください。");
	}

# データファイルを更新
&Datafile("Me Renew Action",%status);

# タイトル定義
$main::sub_title = qq(アクション | $init{'title'});
$main::head_link3 = qq( &gt; アクション);

# ジャンプ
#$main::jump_url = "./";
#$main::jump_sec = 5;

# インデックスを表示
&Index("Link-to-back",$this_title,"$message $message2");

exit;


}


#-----------------------------------------------------------
# 敵を迎え討つ
#-----------------------------------------------------------
sub Fight{

# 宣言
my($type,$select,%status) = @_;
my(%init) = &Init();
my($message,$killed_monster,$get_exp,$this_title);
my($return_link);

	# このアクションのタイトル定義
	$this_title = qq(敵を迎え討つ);

	# 基本リンク
	$return_link = qq($this_title($status{'fight_count'}/$status{'fight_maxcount'}));

	# ゴールドが足りない場合
	if($status{'fight_count'} <= 0){
			if($type =~ /Get-link/){ return qq($return_link\n); }
			else{ main::error("今日はもう戦えません。"); }
	}
	if($status{'monster'} <= 0){
			if($type =~ /Get-link/){ return qq($this_title(魔物不足)\n); }
			else{ main::error("魔物がいなくて戦えません。回復してください。"); }
	}

	# リンク取得の場合、リターン
	if($type =~ /Get-link/){
		$return_link = qq(<a href="./?mode=go&amp;type=fight&amp;action_salt=$status{'action_salt'}"$init{'white_style'}$main::sikibetu>$return_link</a>\n);
	return($return_link);
	}


# ステータスを調整
$killed_monster = int(rand(5))+1;
$status{'monster'} -= $killed_monster;
if($status{'monster'} <= 0){ $status{'monster'} = 0; }

# 経験値の処理
$get_exp = int(rand(10))+1;
$status{'exp'} += $get_exp;


# 戦闘履歴を調整
$status{'fight_count'} -= 1;
$status{'lastfight_yearmonthday'} = "$main::thisyear-$main::thismonthf-$main::todayf";
$message = qq(敵と戦った！　魔物が$killed_monster体減った。 $get_exp の経験を積んだ。);

	# レベルアップ処理
	if($status{'exp'} > $status{'nextexp'}){
		$status{'level'} += 1;
		$status{'aube'} += 1;
		$status{'exp'} -= $status{'nextexp'};
		$message .= qq(<br$main::xclose>レベルアップ！ レベルが $status{'level'} になり、オーブが $status{'aube'}個に増えた。);
	}

	# HPがなくなりダウンした場合
	if($status{'monster'} <= 0){
		$status{'downtime'} = $main::time + 30*60;
		$message .= qq(<br$main::xclose>魔物がゼロになり、あなたはダウンしてしまった！);
	}

# リターン
return($message,$this_title,%status);

}


#-----------------------------------------------------------
# オーブ
#-----------------------------------------------------------
sub Aube{

# 宣言
my($type,$select,%status) = @_;
my(%init) = &Init();
my($line,$h1,$message,$this_title);

	# このアクションのタイトル定義
	$this_title = qq(オーブを使う);

	# ステータスが無い場合は取得
	if(!keys(%status)){ (%status) = &Datafile("Me Get"); }

	# 専用ページとして表示する場合
	if($type =~ /Page-view/){

		# 見出しを定義
		$h1 = qq(オーブ);

		# HTML部分
		$line .= qq(<div>);
		$line .= qq(あなたのオーブ： 現在 $status{'aube'} 個　レベルアップするとオーブが増えます。);
		$line .= qq(<ul>);

			# オーブがある場合のみ表示する部分
			if($status{'aube'} >= 1){
				$line .= qq(<li><a href="./?mode=go&amp;type=aube&amp;select=yellow&amp;action_salt=$status{'action_salt'}"$init{'white_style'}$main::sikibetu>イエローオーブ</a></li>);
				$line .= qq(<li><a href="./?mode=go&amp;type=aube&amp;select=green&amp;action_salt=$status{'action_salt'}"$init{'white_style'}$main::sikibetu>グリーンオーブ</a></li>);
				$line .= qq(<li><a href="./?mode=go&amp;type=aube&amp;select=purple&amp;action_salt=$status{'action_salt'}"$init{'white_style'}$main::sikibetu>パープルオーブ</a></li>);
			}
			else{
				$line .= qq(<li>選べる身分じゃありません。</li>);	
			}

		# HTML部分
		$line .= qq(</ul>);
		$line .= qq(</div>);

		# 専用ページとして表示する
		&Index("Only-view Navi-links",$h1,$line);

	}

	# オーブを使う
	if($type =~ /Use/){

		# オーブが無い場合
		if($status{'aube'} <= 0){ main::error("オーブは１個もありません。"); }

		# 失敗した場合
		if(rand(3.5) < 1){
			$message = qq(失敗した。オーブは粉々に砕け散り、暗い闇の中へと溶けていった。);
		}

		# 収入を増やす
		elsif($select eq "yellow"){
			$status{'income'} += int(rand(2)) + 1;
			$message = qq(オーブを使った！ 収入を増やした。);
		}

		# 最大討伐数を増やす
		elsif($select eq "green"){
			$status{'fight_maxcount'} += 1;
			$status{'fight_count'} = $status{'fight_maxcount'};
			$message = qq(オーブを使った！ 最大討伐数を 1 増やした。);
		}

		# 魔物の最大数を上げる
		elsif($select eq "purple"){
			$status{'monster_max'} += int(rand(2)) + 1;
			$status{'monster'} = $status{'monster_max'};
			$message = qq(オーブを使った！ 魔物の最大数を増やした。);
		}

		# 選択が無い場合
		else{
			main::error("オーブの使い先を指定してください。");
		}

		# オーブ個数を減らす
		$status{'aube'} -= 1;
	}


# リターン
return($message,$this_title,%status);

}


#-----------------------------------------------------------
# 迷宮を強くする
#-----------------------------------------------------------
sub Buy{

# 宣言
my($type,$select,%status) = @_;
my(%init) = &Init();
my($message,$spend_gold,$plused_monster,$return_link,$this_title);

# 魔物の値段
$spend_gold = 10;

	# このアクションのタイトル定義
	$this_title = qq(魔物を増員);

	# 基本リンク
	if($type =~ /Get-link/){
		$return_link = qq($this_title($status{'monster'}/$status{'monster_max'}));
	}

	# ゴールドが足りない場合
	if($status{'gold'} < $spend_gold){
			if($type =~ /Get-link/){ return qq($this_title($status{'monster'}/$status{'monster_max'})\n); }
		main::error("お金が足りません。");
	}
	
	# 魔物がマックスの場合
	if($status{'monster'} >= $status{'monster_max'}){
			if($type =~ /Get-link/){ return qq($this_title($status{'monster'}/$status{'monster_max'})\n); }
		main::error("魔物がいっぱいです。");
	}

	# 判定のみの場合リターン
	if($type =~ /Get-link/){
		return qq(<a href="./?mode=go&amp;type=buy&amp;action_salt=$status{'action_salt'}"$init{'white_style'}$main::sikibetu>$return_link</a>\n);
	}

# ゴールド調整
$status{'gold'} -= $spend_gold;

# 魔物を増やす
$plused_monster = int(rand(3))+1;
$status{'monster'} += $plused_monster;

# メッセージ
$message = qq($spend_gold Gで魔物を $plused_monster体増員した。);

# リターン
return($message,$this_title,%status);

}

#-----------------------------------------------------------
# 税金を徴収する
#-----------------------------------------------------------
sub Levy{

# 宣言
my($type,$select,%status) = @_;
my(%init) = &Init();
my($message,$return_link,$this_title);

	# このアクションのタイトル定義
	$this_title = qq(税金を徴収);

	# リンク定義
	$return_link = qq($this_title($status{'income'}G/1h));

	# 徴収データがない場合、 1時間分 を代入する
	if($status{'lastlevytime'} eq ""){ $status{'levygold'} = $status{'income'}*1; }

	# 徴収できる金額がない場合
	if($status{'levygold'} <= $status{'income'} / 6){
			if($type =~ /Get-link/){ return qq($this_title($status{'income'}G/1h)\n); }
			else{ main::error("徴収できる金額がありません。臣民の貯金が溜まるのを待ってください。"); }
	}

	# リンクを返す場合
	if($type =~ /Get-link/){
		return qq(<a href="./?mode=go&amp;type=levy&amp;action_salt=$status{'action_salt'}"$init{'white_style'}$main::sikibetu>$return_link</a>\n);
	}

# モンスターを増やす
$status{'gold'} += $status{'levygold'};
$status{'lastlevytime'} = $main::time;
$message = qq(臣民から$status{'levygold'} Gを徴収した。);

# リターン
return($message,$this_title,%status);

}

#-----------------------------------------------------------
# 設定編集
#-----------------------------------------------------------
sub Edit{

# 宣言
my($type,$select,%status) = @_;
my(%init) = &Init();
my($message,$return_link,$this_title,$edit_form);

	# タイトル定義
	$this_title = "設定編集";

	# メッセージを定義
	$message = qq(設定を編集した。);

	# 内容を編集
	if($type =~ /Edit/){
		require "${main::int_dir}regist_allcheck.pl";
		$status{'handle'} = $main::in{'handle'};
		$status{'dungeon_handle'} = $main::in{'dungeon_handle'};
		($status{'handle'}) = Mebius::Regist::HandleCheck(undef,$status{'handle'});
		($status{'dungeon_handle'}) = Mebius::Regist::HandleCheck(undef,$status{'dungeon_handle'});
		main::error_view();
	}

	# 編集フォームを取得
	if($type =~ /Get-form/){
		$edit_form .= qq(<h2$main::kfontsize_h2>編集</h2>);
		$edit_form .= qq(<form action="./" method="post"$main::sikibetu><div>\n);
		$edit_form .= qq(<input type="hidden" name="moto" value="games">\n);
		$edit_form .= qq(<input type="hidden" name="game" value="dungeon">\n);
		$edit_form .= qq(<input type="hidden" name="mode" value="go">\n);
		$edit_form .= qq(<input type="hidden" name="type" value="edit">\n);
		$edit_form .= qq(<input type="hidden" name="action_salt" value="$status{'action_salt'}">\n);
		$edit_form .= qq(名前<input type="text" name="handle" value="$status{'handle'}">\n);
		$edit_form .= qq(ダンジョンの名前<input type="text" name="dungeon_handle" value="$status{'dungeon_handle'}">\n);
		$edit_form .= qq(<input type="submit" value="決定">\n);
		$edit_form .= qq(</div></form>\n);
		return($edit_form);
	}

# リターン
return($message,$this_title,%status);

}


#-----------------------------------------------------------
# 新規登録
#-----------------------------------------------------------
sub Newstart{

# 宣言
my($type) = @_;
my(%init) = &Init();
my(%renew,$flag,$message);

# 基本ディレクトリを作成
Mebius::Mkdir("","${main::int_dir}_dungeon",$main::dirpms);
Mebius::Mkdir("","${main::int_dir}_dungeon/_member_dungeon",$main::dirpms);

# データファイルを更新
($flag) = &Datafile("Me Newstart Renew");

# メッセージを定義
$message = qq(新規登録しました！);

# インデックスを表示
&Index("Newstart",undef,$message);

exit;

}





#-----------------------------------------------------------
# ステータス表示部分
#-----------------------------------------------------------
sub Status{

# 宣言
my($type,$file) = @_;
my(%init) = &Init();
my($status_line,%status,%mystatus,$mydata_flag);

# CSS定義
#$main::css_text .= qq(
#div.status_left{float:left;}
#);

	# データファイルを取得
	if($type =~ /Select/){
		(%status) = &Datafile("Get",$file);
		(%mystatus) = &Datafile("Me Get");
	}
	else{
		(%status) = &Datafile("Me Get");
	}

	# 自分を認識
	if($status{'file'} && $status{'file'} eq $mystatus{'file'}){ $mydata_flag = 1; }

	# データが存在しない場合
	if($status{'key'} eq ""){
		if($type =~ /Select/){ main::error("キャラデータが存在しません。"); }
		else{ return(); }
	}

	# 表示部分を整形
	if($status{'key'} eq "1"){
		$status_line .= qq(<ul>);
		#$status_line .= qq(</ul>);
		#$status_line .= qq(<ul>);
			if($type =~ /Detail/){ $status_line .= qq(<li>名前： $status{'handle'}</li>); }
			if($type =~ /Detail/){ $status_line .= qq(<li>ダンジョンの名前： $status{'dungeon_handle'}</li>); }
		$status_line .= qq(<li>レベル： $status{'level'}</li>);
		$status_line .= qq(<li>経験： $status{'exp'} / $status{'nextexp'}</li>);
		$status_line .= qq(<li>資金： $status{'gold'} G</li>);
			if($type =~ /Detail/){ $status_line .= qq(<li>魔物： $status{'monster'} / $status{'monster_max'}</li>); }
			if($type =~ /Detail/){ $status_line .= qq(<li>収入： $status{'income'} G / 1時間</li>); }
			if($type =~ /Detail/){ $status_line .= qq(<li>オーブ： $status{'aube'}</li>); }
			if($type =~ /Detail/){ $status_line .= qq(<li>最大討伐数： $status{'fight_maxcount'}</li>); }
		$status_line .= qq(</ul>);
	}
	else{ $status_line = qq(ステータスはありません。); }

	# 整形
	if($type =~ /Detail/){
		$status_line = qq(
			$main::khrtag<h2$main::kfontsize_h2>ステータス - $status{'file'}</h2>
			<div class="status"$status_line</div>
			);
	}
	else{
		$status_line = qq(
			$main::khrtag<h2$main::kfontsize_h2>	<a href="./status-$status{'file'}"$init{'white_style'}$main::sikibetu>ステータス - $status{'file'}</a></h2>
			<div class="status">$status_line</div>
		);
	}

	# 管理者や自分自身の場合、編集フォームを表示
	if($type =~ /Page-view/ && ($main::myadmin_flag || $mydata_flag)){
		my($edit_form) = &Edit("Get-form",undef,%status);
		$status_line .= $edit_form;
	}

	# そのままステータスページを表示する場合
	if($type =~ /Page-view/){
		&Index("Only-view Navi-links Status-view","$status{'allhandle'} のステータス",$status_line);
	}

# 余計なタブを整形
$status_line =~ s/\t//g;

# リターン
return($status_line,%status);

}


#-----------------------------------------------------------
# 自分のデータを開く
#-----------------------------------------------------------
sub Datafile{

# 宣言
my($type,$file) = @_;
my(undef,%renew) = @_;
my(%init) = &Init();
my($statusfile,$status_handler,$nextexp);
my(%top,$allhandle);
my(%status,@renewline,$gethost,$levygold,$fight_flag,$i,$down_flag);

	# ボットは自データを取得できない
	if($type =~ /Me/ && $main::bot_access){ return(); }

	# 登録できない環境
	if($type =~ /Renew/){
			#if($main::k_access && !$main::kaccess_one){
			#	main::error("実行できませんでした。固体識別番号を送信、またはオンにしてください。");
			#}
			if(!$main::pmfile && !$main::kaccess_one){
				my($enc_backurl_dungeon) = Mebius::Encode("",$init{'dungeon_url'});
				main::error("実行できませんでした。このゲームをプレイするには<a href=\"${main::auth_url}?backurl=$enc_backurl_dungeon\">アカウントにログイン（または登録）</a>してください。");
			}
	}

	# アクセス制限
	if($type =~ /Renew/){ ($gethost) = main::axscheck(""); }

	# 自分の場合のファイル定義
	if($type =~ /Me/){

		my($mobile_hash);
		my($read_device) = Mebius::my_real_device();

			# 固体識別番号からハッシュを作成
			if($main::k_accesses){
				($mobile_hash) = Mebius::Crypt("MD5",$main::k_accesses,"4F");
				($mobile_hash) = Mebius::Crypt("MD5",$mobile_hash,"Bt");
				$mobile_hash =~ s/[^a-zA-Z0-9]//g;
				$mobile_hash = qq(_$mobile_hash);
			}

		if($mobile_hash){ $file = $mobile_hash; }
		elsif($main::pmfile){ $file = $main::pmfile; }
		else{ return(0); }
	}

	# ファイル定義
	$file =~ s/[^a-zA-Z0-9_-]//g;
	if($file eq ""){ return(0); }
	$statusfile = "${main::int_dir}_dungeon/_member_dungeon/${file}_member_dungeon.log";

	# 二度は新規登録できない
	if($type =~ /Newstart/ && -e $statusfile){ main::error("もう登録済みです。"); }

	# データファイルがない場合の処理
	if(!-e $statusfile){ 
			if($type =~ /Newstart/){ Mebius::Fileout("NEWMAKE",$statusfile); }
			elsif($type =~ /Renew/){ main::error("キャラデータが存在しません。"); }
			else{ return(0); }
	}


# データファイルを開く
open($status_handler,"+<$statusfile");
flock($status_handler,2);

	# ファイルを展開、１行ずつトップデータとして定義
	while(<$status_handler>){
		$i++;
		chomp;
		$top{$i} = $_;
	}

# 各種データを分解
my($key,$count,$action_salt,$handle,$dungeon_handle) = split(/<>/,$top{'1'});
my($firsttime,$firsthost,$firstagent,$firstcnumber,$firstencid) = split(/<>/,$top{'2'});
my($lasttime,$lasthost,$lastagent,$lastcnumber,$lastencid) =  split(/<>/,$top{'3'});
my($hp,$maxhp,$mp,$maxmp,$sp,$maxsp,$gold,$income,$exp,$level,$aube) = split(/<>/,$top{'4'});
my($downtime,$lastlevytime) = split(/<>/,$top{'5'});

my($monster,$monster_max) = split(/<>/,$top{'6'});

my($lastfight_yearmonthday,$fight_count,$fight_maxcount) = split(/<>/,$top{'11'});

	# ダウンしている場合
	if($main::time < $downtime){
		my($leftsplittime) = Mebius::SplitTime("",$downtime-$main::time);
		$down_flag = qq(ダウン中のため行動できません。（あと$leftsplittime）);
	}

	# 画面更新による連続行動を禁止
	if($type =~ /Action/ && $action_salt && $action_salt ne $main::in{'action_salt'}){
		close($status_handler);
		Mebius::Redirect("",$init{'dungeon_url'},301);
		main::error("画面更新による連続行動は出来ません。またブラウザの戻り機能\を使うと、正常に送信できない場合があります。");
	}

	# 戦闘カウントの処理
	if($lastfight_yearmonthday ne "$main::thisyear-$main::thismonthf-$main::todayf"){
		$fight_count = $fight_maxcount;
	}
	
	# 徴収できる金額を計算
	if($lastlevytime){ $levygold = int ( ( ($main::time - $lastlevytime) / (60*60) ) * $income); }
	if($levygold > $income * 24){ $levygold = $income * 24; }

	# 完全なハンドルネーム
	if($handle){ $allhandle = qq($handle - $file); }
	else{ $allhandle = qq($file); }

	# 次回レベルアップの経験値を計算
	$nextexp = $level*10;

	# ●ハッシュにしてデータを返す場合
	#if($type =~ /Get/){

		# データをハッシュ化
		%status = (
			key=>$key , handle=>$handle , dungeon_handle => $dungeon_handle ,
			hp=>$hp , sp=>$sp , maxhp=>$maxhp, gold=>$gold , income=>$income , exp=>$exp , level=>$level , aube=>$aube ,
			downtime => $downtime , lastlevytime => $lastlevytime ,
			action_salt => $action_salt,
			monster => $monster , monster_max => $monster_max, 
			fight_count => $fight_count , fight_maxcount => $fight_maxcount , 
			file => $file, levygold => $levygold, fight_flag => $fight_flag , nextexp=>$nextexp , down_flag => $down_flag , allhandle=>$allhandle ,
		);

	#}

	# ●ファイル更新時の書き込みデータを定義
	if($type =~ /Renew/){

		# 更新カウントを増やす
		$count++;

		# IDを取得する
		my($encid) = main::id();

			# 新規登録の場合、基本データを追加する
			if($type =~ /Newstart/){
				$key = 1;
				$firsttime = $main::time;
				$firsthost = $gethost;
				$firstagent = $main::agent;
				$firstcnumber = $main::cnumber;
				$firstencid = $encid;
			}

			# 必須データがない場合、データを代入する（主に新規登録時）
			if($hp eq ""){ $hp = 20; }
			if($maxhp eq ""){ $maxhp = 20; }
			if($mp eq ""){ $mp = 20; }
			if($maxmp eq ""){ $maxmp = 20; }
			if($sp eq ""){ $sp = 20; }
			if($maxsp eq ""){ $maxsp = 20; }
			if($gold eq ""){ $gold = 200; }
			if($income eq ""){ $income = 20; }
			if($lastlevytime eq ""){ $lastlevytime = $main::time - 6*60*60; }
			if($monster eq ""){ $monster = 50; }
			if($monster_max eq ""){ $monster_max = 50; }
			if($fight_count eq ""){ $fight_count = 10; }
			if($fight_maxcount eq ""){ $fight_maxcount = 10; }

			
			# データ変更
			if($renew{'handle'} ne ""){ $handle = $renew{'handle'}; }
			if($renew{'dungeon_handle'} ne ""){ $dungeon_handle = $renew{'dungeon_handle'}; }
			if($renew{'hp'} ne ""){ $hp = $renew{'hp'}; }
			if($renew{'monster'} ne ""){ $monster = $renew{'monster'}; }
			if($renew{'monster_max'} ne ""){ $monster_max = $renew{'monster_max'}; }
			if($renew{'gold'} ne ""){ $gold = $renew{'gold'}; }
			if($renew{'downtime'} ne ""){ $downtime = $renew{'downtime'}; }
			if($renew{'lastlevytime'} ne ""){ $lastlevytime = $renew{'lastlevytime'}; }
			if($renew{'income'} ne ""){ $income = $renew{'income'}; }
			if($renew{'exp'} ne ""){ $exp = $renew{'exp'}; }
			if($renew{'level'} ne ""){ $level = $renew{'level'}; }
			if($renew{'aube'} ne ""){ $aube = $renew{'aube'}; }
			if($renew{'fight_count'} ne ""){ $fight_count = $renew{'fight_count'}; }
			if($renew{'fight_maxcount'} ne ""){ $fight_maxcount = $renew{'fight_maxcount'}; }
			if($renew{'lastfight_yearmonthday'} ne ""){ $lastfight_yearmonthday = $renew{'lastfight_yearmonthday'}; }

			# 接続データ等を記録
			if($type =~ /Me/){
				$lasthost = $gethost;
				$lastagent = $main::agent;
				$lastcnumber = $main::cnumber;
				$lastencid = $encid;
				$lasttime = $main::time;
			}

			# アクションソルトを設定
			if($type =~ /Me/){ $action_salt = int rand(99999999); }

		# 更新行を追加する ( 基本データ )
		push(@renewline,"$key<>$count<>$action_salt<>$handle<>$dungeon_handle<>\n");
		push(@renewline,"$firsttime<>$firsthost<>$firstagent<>$firstcnumber<>$firstencid<>\n");
		push(@renewline,"$lasttime<>$lasthost<>$lastagent<>$lastcnumber<>$lastencid<>\n");
		push(@renewline,"$hp<>$maxhp<>$mp<>$maxmp<>$sp<>$maxsp<>$gold<>$income<>$exp<>$level<>$aube<>\n");
		push(@renewline,"$downtime<>$lastlevytime<>\n");

		# 更新行を追加する ( ダンジョン関係 )
		push(@renewline,"$monster<>$monster_max<>\n");
		push(@renewline,"<>\n");
		push(@renewline,"<>\n");
		push(@renewline,"<>\n");
		push(@renewline,"<>\n");

		# 更新行を追加する ( 戦闘関係 
		push(@renewline,"$lastfight_yearmonthday<>$fight_count<>$fight_maxcount<>\n");
		push(@renewline,"<>\n");
		push(@renewline,"<>\n");
		push(@renewline,"<>\n");
		push(@renewline,"<>\n");

		# 更新行を追加する ( アイテム関係 ） 
		push(@renewline,"<>\n");
		push(@renewline,"<>\n");
		push(@renewline,"<>\n");
		push(@renewline,"<>\n");
		push(@renewline,"<>\n");
	}

	# ファイルを更新
	if($type =~ /Renew/){
		seek($status_handler,0,0);
		truncate($status_handler,tell($status_handler));
		print $status_handler @renewline;
	}

# データファイルを閉じる
close($status_handler);

		# メンバーファイルを更新
		if($type =~ /Renew/){
			&Member("Renew",$file,%status);
		}


# ハッシュをリターン
return(%status);


}


#-----------------------------------------------------------
# メンバーファイル
#-----------------------------------------------------------
sub Member{

# 宣言
my($type,$file,%status) = @_;
my($member_handler,$memberfile,$top1,@renewline,$i_member,$index_line);
my(%init) = &Init();

# ファイル定義
$memberfile = qq(${main::int_dir}_dungeon/member_dungeon.log);

# ファイルが無い場合は作成
if($type =~ /Renew/ && !-e $memberfile){ Mebius::Fileout("NEWMAKE",$memberfile); }

	# データファイルを開く
	open($member_handler,"+<$memberfile");

			# ファイルロック
			if($type =~ /Renew/){ flock($member_handler,2); }

		# トップデータを分解
		$top1 = <$member_handler>;
		my($tkey,$tlasttime) = split(/<>/,$top1);
		
			# ファイルを展開
			while(<$member_handler>){

				# ラウンドカウンタ
				$i_member++;

				# 最大行数に達した場合
				if($i_member >= 500){ next; }

				# この行を分解
				chomp;
				my($key2,$file2,$lasttime2,$allhandle2,$level2) = split(/<>/,$_);

				# ▼メンバーリスト取得用
				if($type =~ /Index/){

					# インデックス行を追加
					$index_line .= qq(<li><a href="./status-$file2"$init{white_style}$main::sikibetu>$allhandle2</a> (Lv.$level2)</li>);
				
				}

				# ▼ファイル更新用
				if($type =~ /Renew/){

					# 自分の場合はエスケープ
					if($file2 eq $file){ next; }

					# 追加する行
					push(@renewline,"$key2<>$file2<>$lasttime2<>$allhandle2<>$level2<>\n")

				}

			}

		# 新しく追加する行
		if($type =~ /Renew/){ unshift(@renewline,"1<>$file<>$main::time<>$status{'allhandle'}<>$status{'level'}<>\n") }

		# トップデータを追加
		if($type =~ /Renew/){
			if($tkey eq ""){ $tkey = 1; }
			unshift(@renewline,"$tkey<>$main::time<>\n");
		}

		# ▼ファイルを更新
		if($type =~ /Renew/){
			seek($member_handler,0,0);
			truncate($member_handler,tell($member_handler));
			print $member_handler @renewline;
		}

	close($member_handler);

	# インデックスをリターン
	if($type =~ /Index/){
		if($type =~ /Page-view/){ &Index("Only-view Navi-links","参加者一覧",$index_line); }
		else{ return($index_line); }
	}

# リターン
return(1);

}


#-----------------------------------------------------------
# コメントアウト
#-----------------------------------------------------------

#		<form action="./" method="post"$main::sikibetu>
#		<div>
#		<input type="hidden" name="moto" value="games">
#		<input type="hidden" name="game" value="dungeon">
#		<input type="hidden" name="mode" value="go">
#		<input type="hidden" name="action_salt" value="$status{'action_salt'}">
#		<input type="submit" value="ミッション開始">
#		</div>
#		</form>

1;
