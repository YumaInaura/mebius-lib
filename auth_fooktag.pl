
use Mebius::Tag;
package main;

#-----------------------------------------------------------
# ＳＮＳ 関連タグの登録
#-----------------------------------------------------------
sub auth_fooktag{

# 局所化
my($type,$file,$maxtag,$max_comment) = @_;
my($line,$file2,$fooktag,$tag);

# GET送信を禁止
if(!$postflag){ &error("ちゃんとPOSTしてね。"); }

# ログイン中のみ
if(!$idcheck){ &error("しっかりログインしてください。"); }

# エンコード
$file2 = $submode3;
$file2 =~ s/([^\w])/'%' . unpack('H2' , $1)/eg;
$file2 =~ tr/ /+/;

# タグの整形
$tag = $in{'tag'};
($tag) = Mebius::Tag::FixTag(undef,$tag);

# エンコード２
$fooktag = $tag;
$fooktag =~ s/([^\w])/'%' . unpack('H2' , $1)/eg;

# 閉鎖ファイルを開く１
open(CLOSE_IN1,"${int_dir}_authlog/_closetag/${file2}_close.cgi");
my $top_close1 = <CLOSE_IN1>;
close(CLOSE_IN1);
my($close_key1) = split(/<>/,$top_close1);
if($close_key1 eq "0" || $close_key1 eq "2"){ &error("閉鎖中のタグですがな。"); }

# 閉鎖ファイルを開く２
open(CLOSE_IN2,"${int_dir}_authlog/_closetag/${fooktag}_close.cgi");
my $top_close2 = <CLOSE_IN2>;
close(CLOSE_IN2);
my($close_key2) = split(/<>/,$top_close2);
if($close_key2 eq "0" || $close_key2 eq "2"){ &error("閉鎖中のタグですわい。"); }


# タグが存在するかどうかをチェック１
open(TAG_IN1,"${int_dir}_authlog/_tag/${file2}.cgi");
my $top_tag1 = <TAG_IN1>;
close(TAG_IN1);
if($top_tag1 eq ""){ &error("このタグはありませんよ。${file2}"); }

# タグが存在するかどうかをチェック２
open(TAG_IN2,"${int_dir}_authlog/_tag/${fooktag}.cgi");
my $top_tag2 = <TAG_IN2>;
close(TAG_IN2);
if($top_tag2 eq ""){ &error("登録先のタグがありません。大文字/小文字、半角/全角などに注意して、もう一度登録してください。"); }

# 登録元、登録先のタグが同じ場合
if($file2 eq $fooktag){ &error("同じタグですがや。"); }

# 関連タグを開く１
my($i);
my $fook_line1 .= qq($tag<>\n);
open(FOOK_IN1,"${int_dir}_authlog/_fooktag/${file2}_fk.cgi");
while(<FOOK_IN1>){
my($word) = split(/<>/,$_);
if($word eq $tag){ $nextflag++; next; }
$i++;
if($i >= 5){ last; }
$fook_line1 .= $_;
}
close(FOOK_IN1);

# 関連タグを開く２
my($i);
my $fook_line2 .= qq($submode3<>\n);
open(FOOK_IN2,"${int_dir}_authlog/_fooktag/${fooktag}_fk.cgi");
while(<FOOK_IN2>){
my($word) = split(/<>/,$_);
if($word eq $submode3){ $nextflag++; next; }
$i++;
if($i >= 5){ last; }
$fook_line2 .= $_;
}
close(FOOK_IN2);

# 双方共に登録済みの場合
if($nextflag >= 2){ &error("既に登録済みでガス。"); }

# 関連タグを登録１
open(FOOK_OUT1,">${int_dir}_authlog/_fooktag/${file2}_fk.cgi");
print FOOK_OUT1 $fook_line1;
close(FOOK_OUT1);
Mebius::Chmod(undef,"${int_dir}_authlog/_fooktag/${file2}_fk.cgi");


# 関連タグを登録２
open(FOOK_OUT2,">${int_dir}_authlog/_fooktag/${fooktag}_fk.cgi");
print FOOK_OUT2 $fook_line2;
close(FOOK_OUT2);
Mebius::Chmod(undef,"${int_dir}_authlog/_fooktag/${fooktag}_fk.cgi");

# ページジャンプ
$jump_sec = $auth_jump;
$jump_url = "./tag-word-${file2}.html";
if($aurl_mode){ ($jump_url) = &aurl($jump_url); }

# HTML
my $print = qq(
関連タグを登録しました（<a href="$jump_url">→戻る</a>）。<br>
);

Mebius::Template::gzip_and_print_all({},$print);

exit;

}

1;
