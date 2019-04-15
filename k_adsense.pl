
sub do_kadsense{

# 局所化
my($type) = @_;
my($line,$channel,$line2);

# チャネル判定
if($type =~ /INDEX/){ $channel = "8521816570"; }
elsif($type =~ /OTHER/){ $channel = "3823612922"; }
else{ $channel ="3406336112"; }

use LWP::UserAgent;
use Time::HiRes qw(gettimeofday);
use URI::Escape;

sub google_append_color {
  my @color_array = split(/,/, $_[0]);
  return $color_array[$_[1] % @color_array];
}

sub google_append_screen_res {
  my $screen_res = $ENV{"HTTP_UA_PIXELS"};
  if ($screen_res == "") {
    $screen_res = $ENV{"HTTP_X_UP_DEVCAP_SCREENPIXELS"};
  }
  if ($screen_res == "") {
    $screen_res = $ENV{"HTTP_X_JPHONE_DISPLAY"};
  }
  my @res_array = split("[x,*]", $screen_res);
  if (@res_array == 2) {
    return "&u_w=" . $res_array[0] . "&u_h=" . $res_array[1];
  }
}

sub google_append_muid {
  my $muid = $ENV{"HTTP_X_DCMGUID"};
  if ($muid) {
    return "&muid=" . $muid;
  }
  my $muid = $ENV{"HTTP_X_UP_SUBNO"};
  if ($muid) {
    return "&muid=" . $muid;
  }
  my $muid = $ENV{"HTTP_X_JPHONE_UID"};
  if ($muid) {
    return "&muid=" . $muid;
  }
  my $muid = $ENV{"HTTP_X_EM_UID"};
  if ($muid) {
    return "&muid=" . $muid;
  }
}

sub google_append_via_and_accept {
  if ($_[0] eq "") {
    my $via_and_accept;
    my $via = uri_escape($ENV{"HTTP_VIA"});
    if ($via) {
      $via_and_accept = "&via=" . $via;
    }
    my $accept = uri_escape($ENV{"HTTP_ACCEPT"});
    if ($accept) {
      $via_and_accept = $via_and_accept . "&accept=" . $accept;
    }
    if ($via_and_accept) {
      return $via_and_accept;
    }
  }
}

my $google_dt = sprintf("%.0f", 1000 * gettimeofday());
my $google_scheme = ($ENV{"HTTPS"} eq "on") ? "https://" : "http://";
my $google_user_agent = uri_escape($ENV{"HTTP_USER_AGENT"});

my $google_ad_url = "http://pagead2.googlesyndication.com/pagead/ads?" .
  "ad_type=text_image" .
  "&channel=$channel" .
  "&client=ca-mb-pub-7808967024392082" .
  "&color_border=" . google_append_color("FFFFFF", $google_dt) .
  "&color_bg=" . google_append_color("FFFFFF", $google_dt) .
  "&color_link=" . google_append_color("0000CC", $google_dt) .
  "&color_text=" . google_append_color("000000", $google_dt) .
  "&color_url=" . google_append_color("008000", $google_dt) .
  "&dt=" . $google_dt .
  "&format=mobile_single" .
  "&ip=" . uri_escape($ENV{"REMOTE_ADDR"}) .
  "&markup=xhtml" .
  "&oe=sjis" .
  "&output=xhtml" .
  "&ref=" . uri_escape($ENV{"HTTP_REFERER"}) .
  "&url=" . uri_escape($google_scheme . $ENV{"HTTP_HOST"} . $ENV{"REQUEST_URI"}) .
  "&useragent=" . $google_user_agent .
  google_append_screen_res() .
  google_append_muid() .
  google_append_via_and_accept($google_user_agent);

my $google_ua = LWP::UserAgent->new;
my $google_ad_output = $google_ua->get($google_ad_url);
if ($google_ad_output->is_success) {
  $line = $google_ad_output->content;
}


# ●第二広告 ( 導入テスト )
my $google_ua2 = LWP::UserAgent->new;
my $google_ad_output2 = $google_ua2->get($google_ad_url .
"&skip=1");

if ($google_ad_output2->is_success) {
$line2 =  $google_ad_output2->content;
}

return($line,$line2);


}

1;
