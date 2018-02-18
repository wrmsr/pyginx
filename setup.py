import glob
import os
import subprocess
import sys

import setuptools.command.build_py
import setuptools.command.install
import setuptools.dist


BASE_DIR = os.path.dirname(__file__)
ABOUT = {}


def _read_about():
    with open(os.path.join(BASE_DIR, 'pyginx', '__about__.py'), 'rb') as f:
        src = f.read()
        if sys.version_info[0] > 2:
            src = src.decode('UTF-8')
        exec(src, ABOUT)


_read_about()


PACKAGE_DATA = [
    'pyginx/nginx.exe',
]

LICENSE_FILES = [
    'LICENSE',
] + glob.glob('LICENSE-*')


INSTALL_REQUIRES = [
]

EXTRAS_REQUIRE = {
}


class BinaryDistribution(setuptools.dist.Distribution):

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)

        self.libraries = []

    def is_pure(self):
        return False

    def has_c_libraries(self):
        return True


class build_py(setuptools.command.build_py.build_py):

    user_options = setuptools.command.build_py.build_py.user_options + [
        ('nobundled', None, 'do not build bundled assets'),
    ]

    nobundled = False

    def run(self):
        if not self.nobundled:
            if not os.path.exists('pyginx/nginx.exe'):
                subprocess.run(['make', 'clean',  'install'], cwd='nginx', timeout=5*60, check=True)

        super().run()

        for fname in LICENSE_FILES:
            outfile = os.path.join(self.build_lib, 'pyginx', fname)
            dir = os.path.dirname(outfile)
            self.mkpath(dir)
            self.copy_file(fname, outfile, preserve_mode=0)


class install(setuptools.command.install.install):

    def finalize_options(self):
        super().finalize_options()
        if self.distribution.has_ext_modules():
            self.install_lib = self.install_platlib


if __name__ == '__main__':
    setuptools.setup(
        name=ABOUT['__title__'],
        version=ABOUT['__version__'],
        description=ABOUT['__description__'],
        author=ABOUT['__author__'],
        author_email=ABOUT['__author_email__'],
        url=ABOUT['__url__'],

        license='BSD',

        classifiers=[
            'Intended Audience :: Developers',
            'License :: OSI Approved :: BSD License',
            'Programming Language :: Python :: 3',
            'Programming Language :: Python :: Implementation :: CPython',
            'Programming Language :: Python',
        ],

        distclass=BinaryDistribution,

        zip_safe=True,

        setup_requires=['setuptools'],

        packages=setuptools.find_packages(
            include=['pyginx', 'pyginx.*'],
            exclude=['tests', '*.tests', '*.tests.*'],
        ),
        py_modules=['pyginx'],

        package_data={'pyginx': PACKAGE_DATA},
        include_package_data=True,

        cmdclass={
            'build_py': build_py,
            'install': install,
        },

        entry_points={},

        install_requires=INSTALL_REQUIRES,
        extras_require=EXTRAS_REQUIRE,
    )
