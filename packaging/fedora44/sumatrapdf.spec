Name:           sumatrapdf
%global debug_package %{nil}
Version:        26.10.13
Release:        1%{?dist}
Summary:        SumatraPDF ng document reader for Fedora 44
License:        GPL-3.0-or-later AND AGPL-3.0-or-later
URL:            https://github.com/sumatrapdfreader/sumatrapdf
Source0:        %{name}-%{version}.tar.gz
Requires:       dejavu-sans-fonts
Requires:       glibc-gconv-extra

%description
SumatraPDF ng reads PDF, EPUB, MOBI, CHM, XPS, DjVu, comic archives, and
images. This build uses the upstream Linux port and is compiled on Fedora 44.

%prep
%autosetup

%build

%install
install -Dm755 SumatraPDF %{buildroot}%{_bindir}/sumatrapdf
ln -s sumatrapdf %{buildroot}%{_bindir}/SumatraPDF
install -Dm644 sumatrapdf.desktop %{buildroot}%{_datadir}/applications/sumatrapdf.desktop
install -Dm644 sumatrapdf.xml %{buildroot}%{_datadir}/mime/packages/sumatrapdf.xml
for size in 16 24 32 48 64 128 256; do
    install -Dm644 "icons/sumatrapdf-${size}.png" \
        "%{buildroot}%{_datadir}/icons/hicolor/${size}x${size}/apps/sumatrapdf.png"
done

%files
%license COPYING
%doc AUTHORS BUILD-INFO
%{_bindir}/sumatrapdf
%{_bindir}/SumatraPDF
%{_datadir}/applications/sumatrapdf.desktop
%{_datadir}/mime/packages/sumatrapdf.xml
%{_datadir}/icons/hicolor/*/apps/sumatrapdf.png

%changelog
* Tue Oct 13 2026 SumatraPDF Fedora build <noreply@example.invalid> - 26.10.13-1
- Build upstream SumatraPDF ng for Fedora 44
