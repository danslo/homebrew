require 'formula'

class NoExpatFramework < Requirement
  def expat_framework
    '/Library/Frameworks/expat.framework'
  end

  satisfy :build_env => false do
    not File.exist? expat_framework
  end

  def message; <<-EOS.undent
    Detected #{expat_framework}

    This will be picked up by CMake's build system and likely cause the
    build to fail, trying to link to a 32-bit version of expat.

    You may need to move this file out of the way to compile CMake.
    EOS
  end
end

class Cmake < Formula
  homepage 'http://www.cmake.org/'
  url 'http://www.cmake.org/files/v2.8/cmake-2.8.11.tar.gz'
  sha1 '7b7961402ec71d84052734da1bed2b28e6a2c4af'

  bottle do
    sha1 '0bdd4bfd4a094d3fbacbe33d0968161a0f24d665' => :mountain_lion
    sha1 '340f321eed8fd6b423980ecf9bed90646fc9331c' => :lion
    sha1 'c23c8c6124c1d59817301678cabad9517966d899' => :snow_leopard
  end

  depends_on NoExpatFramework

  def install
    args = %W[
      --prefix=#{prefix}
      --system-libs
      --no-system-libarchive
      --datadir=/share/cmake
      --docdir=/share/doc/cmake
      --mandir=/share/man
    ]

    system "./bootstrap", *args
    system "make"
    system "make install"
  end

  test do
    File.open('CMakeLists.txt', 'w') {|f| f.write('find_package(Ruby)') }
    system "#{bin}/cmake", '.'
  end
end
