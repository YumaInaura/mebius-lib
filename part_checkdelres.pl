
#-----------------------------------------------------------
# 削除のお知らせ
#-----------------------------------------------------------
sub checkdelres_view{

# 局所化
my($top,$line,$denymin,$text,$cflag,$text2,$deleted_text);

# タイトル
$sub_title = "ペナルティのお知らせ";
$head_link3 = " &gt; ペナルティのお知らせ";

# CSS定義
$css_text .= qq(
.deleted{padding:1em;border:1px solid #000;}
.comarea{width:95%;height:100px;}
.big{font-size:140%;}
h1{font-size:150%;color:#f00;}
li{line-height:1.4em;}
div.about{line-height:1.4em;}
ul.delguide{border:solid 1px #f00;padding:1em 2em;font-size:90%;color:#f00;margin: 1em 0em;}
);

# 携帯版の場合
if($in{'k'}){ &kget_items(); }

# 実行
&checkdelres_action();

}

#-----------------------------------------------------------
# 基本処理を実行
#-----------------------------------------------------------

sub checkdelres_action{

# 宣言
my($type);
my($file,$file2,$select_dir);
my($count,$allcount,$btime,$oktime,$d_sub,$d_no,$d_res,$d_com,$textarea,$move,$cflag);
our($host);

# ホスト名がない場合は取得する
if(!$host){ ($host) = &Mebius::Gethost("Byaddr"); }

# ファイル定義１
$file = $cnumber;
$file = &enc($file);

# ファイル定義２
if($kaccess_one){ $file2 = "${kaccess_one}_${k_access}"; $select_dir = "_data_kaccess_one/"; }
elsif($k_access){ $file2 = $age; $select_dir = "_data_agent/"; }
else { $file2 = $host; $select_dir = "_data_host/"; }
$file2 = &enc($file2);

# ファイルを開く(Cookie)
if($file){
open(DELRES_IN,"${ip_dir}_data_number/$file.cgi");
my $top = <DELRES_IN>; chomp $top;
($count,$allcount,$btime,$oktime,$d_sub,$d_mtr,$d_url,$d_nita,$d_com,$d_block,$d_rtd,$d_invite,$d_follow) = split(/<>/,$top);
close(DELRES_IN);
}

# ファイルを開く(Host)
if($file2 && $oktime < $time){
open(DELRES_IN,"${ip_dir}${select_dir}$file2.cgi");
my $top = <DELRES_IN>; chomp $top;
($count,$allcount,$btime,$oktime,$d_sub,$d_mtr,$d_url,$d_nita,$d_com,$d_block,$d_rtd,$d_invite,$d_follow) = split(/<>/,$top);
close(DELRES_IN);
}

# 関数の解体
my($d_moto,$d_no,$d_res) = split(/>/,$d_mtr);
my($d_name,$d_id,$d_trip,$d_account) = split(/>/,$d_nita);

# 削除された文章を定義
my $pri_com = $d_com;

# Cookie＋ファイルの制限時間がない場合、待ち時間をCookie独自のものに変更
if($oktime < $time){ $oktime = $cdelres; $cflag = 1; }

# 制限中でない場合
if($oktime < $time){ &error("現在、レスの制限時間はありません。"); }

# 残り時間を定義
$lefthour = int( ($oktime - $time) / (60*60) );
$leftmin = int( ($oktime - $time - ($lefthour*60*60) ) / 60 );

# 文章追加
if(!$cflag){
my $viewres = qq( &gt; No.$d_res ) if($d_res ne "");
$move = qq(（ <a href="#DATA">▼削除データを参照</a> ）);
$deleted_text = qq(<strong class="red">削除された文章</strong>);
if($d_res && $d_moto && $d_no){ $deleted_text .= qq( ( <a href="/_$d_moto/$ktag$d_no.html#S$d_res">$d_sub</a> &gt; <a href="/_$d_moto/$ktag$d_no.html-$d_res#a">No.$d_res</a> ) ); }
elsif($d_url ne ""){ $deleted_text .= qq( ( <a href="/$d_url">$d_sub</a> $viewres ) ); }
else{ $deleted_text .= qq( ( $d_sub $viewres ) ); }
$deleted_text .= qq(<br><br>$pri_com<br><br>);
}

# 投稿内容がある場合
if($in{'comment'} || $in{'prof'}){
my $com = $in{'comment'};
if($com eq ""){ $com = $in{'prof'}; }
$com =~ s/<br>/\n/g;
$textarea = qq(<h2>送信内容（書き込まれていません）</h2><textarea class="comarea" cols="25" rows="5">$com</textarea><br>);

}

my $h1 = qq(<h1>エラー： 送信できませんでした</h1>) if $postflag;

# 表示する文章を定義
$text = qq(
$h1
<h2 id="TELL">ペナルティについて</h2>
<div class="about">
管理者削除（ または管理者の設定 ）により、しばらく送信できません。$move<br>
申\し訳ありませんが、次まで <strong class="red">$lefthour時間$leftmin分</strong> ほどお待ちください。

<ul class="delguide">
<li>削除回数が多いと、ペナルティが重くなったり、投稿制限がかかってしまう場合があります。<br>
<li>詳しくは<a href="${guide_url}%BA%EF%BD%FC%A5%DA%A5%CA%A5%EB%A5%C6%A5%A3%A3%D1%A1%F5%A3%C1">削除ペナルティＱ＆Ａ</a>をご覧ください。Ｑ＆Ａを読んでも不明な点がある場合は「ＵＲＬ」「レス番」などを明記の上、<a href="http://aurasoul.mb2.jp/_delete/${ktag}143.html">「削除への疑問、投稿復活希望」</a>までご連絡ください。
</ul>

</div>
$textarea
<h2 id="DATA">削除データ</h2>

<div class="deleted">
$deleted_text
<strong class="red">主なルール違反のリスト ( 通常、この中に削除理由があります )</strong><br><br>

<ul>
<li><a href="${guide_url}%B0%AD%B8%FD">悪口、罵倒、マナー違反など。</a></li>
<li><a href="${guide_url}%B8%C4%BF%CD%BE%F0%CA%F3">個人情報の書き込み。</a></li>
<li><a href="${guide_url}%B2%E1%BE%EA%C8%BF%B1%FE">荒らしなどへの過剰反応。</a></li>
<li><a href="${guide_url}%CC%C2%CF%C7%C5%EA%B9%C6">ＡＡ、チェーン投稿、マルチポスト、文字の羅列、無意味な書き込み、文字数稼ぎ、デコレーションのしすぎなどの迷惑投稿</a></li>
<li><a href="${guide_url}%C0%AD%C5%AA%A4%CA%C5%EA%B9%C6">性的で思慮のない書き込み。</a></li>
<li><a href="${guide_url}%BB%A8%C3%CC%B2%BD">雑談化（ふさわしくない記事で）。</a></li>
<li><a href="${guide_url}%A5%C1%A5%E3%A5%C3%A5%C8%B2%BD">チャット化（ふさわしくない記事で）。</a></li>
<li><a href="${guide_url}%A5%ED%A1%BC%A5%AB%A5%EB%A5%EB%A1%BC%A5%EB">ローカルルール違反。</a></li>
<li><a href="${guide_url}%A5%AB%A5%C6%A5%B4%A5%EA%B0%E3%A4%A4">カテゴリ違い、記事違いの書き込み。</a></li>
<li><a href="${guide_url}%A5%CA%A5%F3%A5%D1%B9%D4%B0%D9">メールアドレスの書き込み、恋人募集、会う約束、ナンパなど。</a></li>
<li><a href="${guide_url}%C0%EB%C5%C1%C5%EA%B9%C6">流れと関係ない宣伝、無差別な宣伝。</a></li>
<li><a href="${guide_url}%CC%B5%C3%C7%C5%BE%CD%D1">歌詞などの無断転載。</a></li>
<li>下品な言葉や、隠語。</li>
<li>違法な行為、犯罪への誘導。</li>
</ul>

</div><br>

<a href="./$kindex">→ＯＫ！ $titleへ戻る</a>

);


# ヘッダ
if($in{'k'}){ &kheader; } else { &header; }

# HTML
print <<"EOM";
<div class="body1">
$text
</div>
EOM

if($in{'k'}){ print qq(</body></html>); } else{ &footer; }

exit;

}



1;


