
package main;

#-----------------------------------------------------------
# �V���^�O��\��
#-----------------------------------------------------------
sub auth_newtag{

# �Ǐ���
my($tagline,$i,$link1);
my($auth_log_directory) = Mebius::SNS::all_log_directory_path() || die;

# CSS��`
$css_text .= qq(
.list{word-spacing:0.5em;line-height:2.5em;font-size:90%;}
.notice1{}
.notice2{font-size:125%;font-weight:bold;}
.notice3{font-size:140%;font-weight:bold;}
.notice4{font-size:170%;font-weight:bold;}
.notice5{font-size:210%;font-weight:bold;}
.notice6{font-size:210%;font-weight:bold;color:#080;}
.notice7{font-size:210%;font-weight:bold;color:#f55;}
);

# �}�C�^�O�t�@�C�����J��
my $openfile1 = "${auth_log_directory}newtag.cgi";
open(NEWTAG_IN,"<","$openfile1");
	while(<NEWTAG_IN>){

		my($num,$tag) = split(/<>/,$_);
		my($class);
		$i++;


			if($main::device_type eq "mobile" && $i > 100){ last; }

			if(Mebius::Fillter::heavy_fillter(utf8_return($tag))){ next; }

		my $enctag2 = $tag;
		$enctag2 =~ s/([^\w])/'%' . unpack("H2" , $1)/eg;
		$enctag2 =~ tr/ /+/;

		if($num < 10){ }
		elsif($num < 25){ $class = qq( class="notice2"); }
		elsif($num < 50){ $class = qq( class="notice3"); }
		elsif($num < 100){ $class = qq( class="notice4"); }
		elsif($num < 250){ $class = qq( class="notice5"); }
		elsif($num < 500){ $class = qq( class="notice6"); }
		else{ $class = qq( class="notice7"); }

		$tagline .= qq(<a href="./tag-word-${enctag2}.html"$class>$tag</a>\n);
		#if($key eq "2"){ $tagline .= qq(<span class="red">(�폜��)</span>); }
	}
close(NEWTAG_IN);

# ���X�g���`
#if($tagline ne ""){ $tagline = qq(<h2>�V���ꗗ</h2><ul>$tagline</ul>); }
if($tagline ne ""){ $tagline = qq(<h2>�V���ꗗ</h2><div class="list">$tagline</div>); }

# �^�C�g����`
$sub_title = "�V���^�O - $title";
$head_link3 = " &gt; �V���^�O ";

# �^�O�����t�H�[�����擾
&get_schform();

# �i�r�Q�[�V���������N
my($navilink);
$navilink .= qq(<a href="JavaScript:history.go\(-1\)">�O�̉�ʂɖ߂�</a>);
if($idcheck){ $navilink .= qq( - <a href="./$pmfile/tag-view">�^�O��o�^����</a>); }

# HTML
my $print = qq(
$footer_link
<h1>�V���^�O - $title</h1>
$navilink
$schform
$form
$tagline
$footer_link2
);

Mebius::Template::gzip_and_print_all({},$print);

exit;

}

1;
