
# �ݒ�
$title = "�S�R�}����";

# �L��
$ads1 = qq(
<script type="text/javascript"><!--
google_ad_client = "pub-7808967024392082";
/* �S�R�}���� */
google_ad_slot = "5641356314";
google_ad_width = 728;
google_ad_height = 90;
//-->
</script>
<script type="text/javascript"
src="http://pagead2.googlesyndication.com/pagead/show_ads.js">
</script>
);

sub start{


# �����`�F�b�N
$in{'no'} = $mode;
$in{'no'} =~ s/\D//g;

# �t�@�C����`
$file = "../pct/acomic/comic$in{'no'}.GIF";

# CSS��`
$css_text .= qq(
.navi1{word-spacing:1em;margin:0em 0em 1em 0em;}
.navi2{word-spacing:1em;margin:0.5em 0em 0em 0em;}
.body1{text-align:center;}
.img{border-style:none;}
);

# �^�C�g����`
$sub_title = qq(�S�R�}���� - $in{'no'});
$head_link3 = qq( &gt; ��i$in{'no'});


# �摜�����݂��Ȃ��ꍇ
unless(-e $file){ &error("�t�@�C�������݂��܂���B"); };

# �i�r�Q�[�V���������N
my $before = $in{'no'} - 1;
$before_link = qq(<a href="$before.html">���O�̃}���K</a>);
my $next = $in{'no'} + 1;
$next_link = qq(<a href="$next.html">���̃}���K��</a>);
my $top_link = qq(<a href="/">�s�n�o�y�[�W</a>);
my $back_link = qq(<a href="/_acm/">�f����</a>);
my $img_link = qq(<a href="$file">�摜�̂�</a>);
my $form_link = qq(<a href="http://aurasoul.mb2.jp/etc/mail.html">���A��</a>);

# HTML
my $print = <<"EOM";
<div class="navi1">$before_link $top_link $back_link $form_link $img_link $next_link</div>
<div class="ads1">$ads1<br><br></div>
<div class="comic"><img src="$file" alt="�S�R�}���� - $in{'no'}" class="img"><br></div>
<div class="ads1"><br>$ads1</div>
<div class="navi2">$before_link $top_link $back_link $form_link $img_link $next_link</div>
EOM

Mebius::Template::gzip_and_print_all({},$print);

exit;

}

1;
