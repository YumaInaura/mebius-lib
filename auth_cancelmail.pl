
package main;


#-----------------------------------------------------------
# 配信解除
#-----------------------------------------------------------
sub auth_cancelmail{

# 宣言
my(%account,%renew,$file);
our(%in,$title,$jump_sec,$jump_url,$auth_url);

# ファイル定義
$file = $in{'account'};
$file =~ s/[^0-9a-z]//g;
if($file eq ""){ &error("アカウントが存在しません。"); }


# ファイルを開く
(%account) = Mebius::Auth::File("",$file);

# 不足エラー
if($in{'pass'} eq ""){ &error("解除用パスワードを指定してください。"); }
if($account{'mlpass'} eq ""){ &error("認証されていないメールアドレスです。"); }
if($account{'email'} eq ""){ &error("メールアドレス登録がありません。"); }

# パスが合わない場合
if($account{'mlpass'} ne $in{'pass'}){ &error("解除用パスワードが違います。"); }

# メールアドレスを消去
$renew{'email'} = "";
$renew{'mlpass'} = "";

# ファイル更新
Mebius::Auth::File("Renew",$file,\%renew);

# ジャンプ先
$jump_sec = 3;
$jump_url = "$auth_url$file/";


# HTML
my $print = qq($titleのメール配信を解除しました。<a href="$jump_url">移動する</a>);

Mebius::Template::gzip_and_print_all({},$print);

exit;

}

1;

