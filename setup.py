import os
import subprocess
import sys

import setuptools.command.build_ext
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


INSTALL_REQUIRES = [
]

EXTRAS_REQUIRE = {
}


EXT_MODULES = [
]


class BinaryDistribution(setuptools.dist.Distribution):

    def is_pure(self):
        return False


class build_ext(setuptools.command.build_ext.build_ext):

    user_options = setuptools.command.build_ext.build_ext.user_options + [
        ('nobundled', None, 'do not build bundled assets'),
    ]

    nobundled = False

    def run(self):
        if not self.nobundled:
            if not os.path.exists('pyginx/nginx.exe'):
                subprocess.run(['make', 'clean',  'install'], cwd='nginx', timeout=5*60, check=True)
        return super().run()


if __name__ == '__main__':
    setuptools.setup(
        name=ABOUT['__title__'],
        version=ABOUT['__version__'],
        description=ABOUT['__description__'],
        author=ABOUT['__author__'],
        author_email=ABOUT['__author_email__'],
        url=ABOUT['__url__'],

        classifiers=[
            "Intended Audience :: Developers",
            "Programming Language :: Python :: 3",
            "Programming Language :: Python :: Implementation :: CPython",
            "Programming Language :: Python",
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
            'build_ext': build_ext,
        },

        entry_points={},

        install_requires=INSTALL_REQUIRES,
        extras_require=EXTRAS_REQUIRE,

        ext_modules=EXT_MODULES,
    )
