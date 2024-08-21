// gDPI config

String blacklist = "russia-youtube.txt";

// not clear namings, so check the default gDPI repo

// ADD (UPD: who tf needs that???): 
// -f [value]
// -e [value]

// ignore: non_constant_identifier_names
List<List<dynamic>> settings_as_arg = [
  ["Default config", "-5", false],
  ["Best config", "-9", true],
  ["Block passive DPI", "-p", false],
  ["Block QUIC/HTTP3", "-q", false],
  ["Host -> hoSt", "-r", false],
  ["Remove space between header and value", "-s", false],
  ["test.com -> tEsT.com", "-m", false],
  ["Fake Request Mode", "--auto-ttl", false],
  ["Fragment (split) the packets", "--reverse-frag", false],
  ["Skip packets larger than 1200", "--max-payload", false],
  ["Fake Request with TCP SEQ/ACK", "--wrong-seq", false],
  ["Fake Request with incorrect TCP checksum", "--wrong-chksum", false]
];
