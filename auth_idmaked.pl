
package main;


#-------------------------------------------------
# �h�c���쐬���܂���
#-------------------------------------------------
sub auth_idmaked{

my($print);

# CSS��`
$css_text .= qq(
.maked{width:70%;background-color:#fcc;padding:1em;}
);


	# �A�J�E���g�쐬����Q�S���Ԉȓ��ł���΁A

	if($idcheck){

		# �����N��
		my $link = "${pmfile}/";
		my $text = qq(<a href="$link">�}�C�A�J�E���g</a>�ֈړ�����ƁA�f�[�^�̕ҏW�ł��܂��B);

		if($in{'back'} eq "one"){
		$text = qq(���Ƀ}�C���O��<a href="http://aurasoul.mb2.jp/_one/start.html">�V�K�o�^����</a>�����Ă��������B);
		}
		if($aurl_mode){ ($link) = &aurl($link); }

		$print = qq(�A�J�E���g���쐬���܂����B<br>$text<br>);
	}

	# �Q�S���Ԍo�ߌ�A�A�J�E���g����o�`�r�r���Ȃ��ꍇ
	else{
		$print = qq(�A�J�E���g���쐬���܂����B���͂����A�J�E���g���C�p�X���[�h���g����<a href="$auth_url">���O�C��</a>���Ă��������B<br><br>$footer_link2);

	}

Mebius::Template::gzip_and_print_all({},$print);

# �����I��
exit;

}

1;
