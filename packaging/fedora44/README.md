# SumatraPDF para Fedora 44

Build local do SumatraPDF ng para Fedora 44 x86_64. O código parte do commit
`1950ed5bbe538c9897a1cf55336c52b9ca64d680` do repositório oficial, com
as três correções em `fedora44-fixes.patch`.

## Instalar

```sh
sudo dnf install ./sumatrapdf-26.10.13-1.fc44.x86_64.rpm
sumatrapdf arquivo.pdf
```

O RPM registra o aplicativo no menu, os ícones e os tipos MIME. Ele declara as
bibliotecas compartilhadas usadas pelo executável e `glibc-gconv-extra`, que
permite abrir textos em codificações como CP1251 e CP932.

## Código e reprodução

Esta branch contém o código fonte completo e as três correções locais. Para
reconstruir a partir do Git oficial, instale Bun e execute no Fedora 44:

```sh
git clone --branch fedora44 https://github.com/elefantebr/sumatrapdf.git
cd sumatrapdf
bash packaging/fedora44/build-and-install.sh ../sumatrapdf-fedora44-build
```

O script baixa o repositório em uma segunda pasta, seleciona o commit acima, aplica o patch,
compila, instala em `/usr/local/bin` e executa os testes unitários. Para criar
um RPM a partir desse checkout:

```sh
bash packaging/fedora44/package-rpm.sh ../sumatrapdf-fedora44-build .
```

O RPM pré-compilado `sumatrapdf-26.10.13-1.fc44.x86_64.rpm` é um artefato
separado; ele não é armazenado no repositório Git.

## Verificação realizada

- Suíte `test_util`: 104.078 testes aprovados no Fedora 44.
- Renderização de PDF, EPUB, CBZ, DjVu, FB2 e PNG; modelo CHM aberto;
  AZW3 convertido em PDF com três páginas.
- Impressão de PDF em PDF; aplicativo iniciado com um PDF no Xvfb.
- RPM instalado em um contêiner Fedora 44 limpo, com dependências resolvidas.

Essas verificações não comprovam paridade integral com a versão Windows. MOBI,
XPS, CBR, todas as ações da interface e os recursos de assinatura ainda
precisam de testes específicos. O projeto `src/ng` continua evoluindo em
paralelo ao aplicativo original.

Licença: consulte `COPYING` e `AUTHORS` no arquivo de código fonte.
