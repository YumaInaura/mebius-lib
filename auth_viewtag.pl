
package main;

#-----------------------------------------------------------
# アカウント毎のタグ閲覧
#-----------------------------------------------------------
sub auth_viewtag{

# 局所化
my($type,$file,$maxtag,$max_comment) = @_;
my($tagline,$i);

# ファイルオープン
&open($file);

# 最大文字数
my $maxlength = 40;

# ユーザー色指定
if($ppcolor1){
$css_text .= qq(h2{background-color:#$ppcolor1;border-color:#$ppcolor1;});
}

# CSS定義
$css_text .= qq(
.tag_input{width:12em;}
.comment_input{width:15em;}
div.alert{font-size:90%;background-color:#fff;padding:1em;margin-top:1em;border:solid 1px #f00;line-height:1.5em;}
);

# ディレクトリ定義
my($account_directory) = Mebius::Auth::account_directory($file);
	if(!$account_directory){ die("Perl Die! Account directory setting is empty."); }

# マイタグファイルを開く
my $openfile1 = "${account_directory}${file}_tag.cgi";
open(MYTAG_IN,"$openfile1");
	while(<MYTAG_IN>){
		my($key,$tag) = split(/<>/,$_);
			if(Mebius::Fillter::heavy_fillter(utf8_return($tag))){ next; }

		if($key ne "1" && !$myadmin_flag){ next; }
		$i++;
		if($key eq "1"){ $iok++; }
		my $enctag2 = $tag;
		$enctag2 =~ s/([^\w])/'%' . unpack("H2" , $1)/eg;
		$enctag2 =~ tr/ /+/;

		my $link = "${adir}tag-word-${enctag2}.html";
		if($aurl_mode){ ($link) = "$script?mode=tag-word-${enctag2}"; }
		$tagline .= qq(\n<li><a href="$link">$tag</a>);
		if($key eq "2"){ $tagline .= qq(　<span class="red">(削除済)</span>); }
		elsif($myprof_flag || $myadmin_flag){
		if($aurl_mode){ $tagline .= qq( - <a href="$script?mode=tag-delete-${enctag2}&amp;account=$file">削除</a>)}
		else{ $tagline .= qq( - <a href="${adir}?mode=tag-delete-${enctag2}&amp;account=$file">削除</a>); }
		if($myadmin_flag){
		if($aurl_mode){ $tagline .= qq( - (<a href="$script?mode=tag-delete-${enctag2}&amp;account=$file&amp;penalty=1">ペナルティ削除</a>))}
		else{ $tagline .= qq( - (<a href="${adir}?mode=tag-delete-${enctag2}&amp;account=$file&amp;penalty=1">ペナルティ削除</a>)); }
		}
		}
	}
close(MYTAG_IN);

# 待ち時間取得
&get_waittime("",$file);

# 登録ゼロの場合
if(!$iok){ $iok = 0; }

# リスト整形
if($tagline ne ""){ $tagline = qq(<h2>登録中のタグ ($iok)</h2><ul>$tagline</ul>); }

# タグ検索フォームを取得
&get_schform;

# タイトル定義
$sub_title = "$ppnameのタグ - $title";

# HTML
my($form);

# ローカルリンク
if($alocal_mode){
$alocal_links = qq(
<br><a href="$script?mode=tag-new">新着タグ</a>
<a href="$script?mode=tag-sch">タグ検索</a>
);
}


	# ストップモード
	if($myprof_flag && $main::stop_mode =~ /SNS/){
		$form = qq(<h2>タグの登録</h2>\n<div><span class="alert">現在、SNS全体で更新停止中です。</span></div>\n);
	}

# フォーム部分
elsif($myprof_flag){
$form = qq(
<h2>タグの登録</h2>
<form action="$action" method="post" class="myform"$sikibetu>
<div>
タグ： <input type="text" name="tag" value="" maxlength="$maxlength" class="tag_input">
　コメント： <input type="text" name="comment" value="" maxlength="$max_comment" class="comment_input">
　<input type="submit" value="タグを追加する">

<input type="hidden" name="mode" value="tag-maketag">
<input type="hidden" name="account" value="$in{'account'}">

<br>$alocal_links
<div class="alert">
$next_hour
▲「趣味」「性格」「好きなもの」など<strong class="red">あなたに関するキーワード</strong>を登録してください（例： 読書、楽天家）。同じタグ登録しているメンバーとリンクすることが出来ます。<br>
▲タグを使っての「トライアル」「アンケート」「掲示板利用」「チャット」はご遠慮ください（２００９年７月より）。テーマを作って話をする場合は<a href="http://mb2.jp/">掲示板</a>をご利用ください。<br>
<span class="red">▲個人情報、性的なキーワード、バッシング目的、批判・非難目的、罵倒、運営妨害、無意味な単語、迷惑な内容などの登録は禁止です(<a href="${guide_url}%A5%BF%A5%B0">→タグについて</a>)。
管理者がタグを削除すると、しばらくタグが追加できなくなります。また、タグ削除についての管理者説明はありません。</span><br>
▲タグは何かに反対したり、何かを攻撃・批判・非難するためものではありません。発言をおこなうには<a href="http://aurasoul.mb2.jp/">掲示板</a>を利用してください。運営要望などは<a href="http://aurasoul.mb2.jp/_qst/2245.html">質問運営板</a>までお願いします。<br>
▲最大$maxtag件まで登録できます (現在$iok個) 。タグは全角20文字、コメントは全角$max_comment文字まで登録できます。<br>
▲タグ統一のため、一部の記号は自動変換されます。<br>
</div>
</div>
</form>

);
}

my $print = qq(
$footer_link
<h1>$ppname - $ppfile のタグ</h1>
<a href="$adir${file}/">プロフィールへ</a>
 - <a href="${adir}tag-new.html">新着タグをチェックする</a>
$schform
<br>

$form
$tagline
</div>

);

Mebius::Template::gzip_and_print_all({},$print);

exit;

}

#-----------------------------------------------------------
# 次の待ち時間
#-----------------------------------------------------------
sub get_waittime{

my($type,$file) = @_;

# ディレクトリ定義
my($account_directory) = Mebius::Auth::account_directory($file);
	if(!$account_directory){ die("Perl Die! Account directory setting is empty."); }

open(PENALTY_IN,"<","${account_directory}${file}_time_tag.cgi");
my $top = <PENALTY_IN>;
my($nexttime) = split(/<>/,$top);
if($nexttime - $time <= 0){ return; }
$next_hour = int(($nexttime - $time)/3600)-1;
close(PENALTY_IN);
if($next_hour){ $next_hour = qq(▲待ち時間$next_hour時間です。<br>); }
}

1;
