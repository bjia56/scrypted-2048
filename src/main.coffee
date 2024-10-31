import { ScryptedDeviceBase } from '@scrypted/sdk'
import sdk from '@scrypted/sdk'

import { arch, platform } from 'os'
import path from 'path'
import { existsSync, writeFile } from 'fs'
import { mkdir, readdir, rmdir, chmod } from 'fs/promises'

VERSION = 'v0.0.1'
APE_INTERPRETER = 'https://cosmo.zip/pub/cosmos/bin/ape-x86_64.elf'
CACHEBUST = "20241030"

class Scrypted2048Plugin extends ScryptedDeviceBase
    constructor: (nativeId) ->
        super nativeId
        @exe = new Promise (resolve, reject) =>
            @doDownload(resolve).catch(reject)

    doDownload: (resolve) ->
        url = "https://github.com/bjia56/2048-in-terminal/releases/download/#{VERSION}/2048.com"

        pluginVolume = process.env.SCRYPTED_PLUGIN_VOLUME
        installDir = path.join pluginVolume, "2048-#{VERSION}-#{CACHEBUST}"

        unless existsSync installDir
            console.log "Clearing old 2048 installations"
            existing = await readdir pluginVolume
            existing.forEach (file) =>
                if file.startsWith '2048-'
                    try
                        await rmdir path.join(pluginVolume, file), { recursive: true }
                    catch e
                        console.error e

            await mkdir installDir, { recursive: true }

            console.log "Downloading 2048"
            console.log "Using url: #{url}"
            response = await fetch url
            unless response.ok
                throw new Error "failed to download 2048: #{response.statusText}"

            file = await response.arrayBuffer()

            # write the file
            await new Promise (resolve, reject) =>
                writeFile path.join(installDir, '2048.com'), Buffer.from(file), (err) =>
                    if err
                        reject err
                    else
                        resolve()

            if arch() == 'x64' and platform() == 'linux'
                console.log "Downloading APE interpreter"
                response = await fetch APE_INTERPRETER
                unless response.ok
                    throw new Error "failed to download APE interpreter: #{response.statusText}"

                file = await response.arrayBuffer()

                # write the file
                await new Promise (resolve, reject) =>
                    writeFile path.join(installDir, 'ape-x86_64.elf'), Buffer.from(file), (err) =>
                        if err
                            reject err
                        else
                            resolve()

        exe = path.join installDir, '2048.com'
        unless platform() == 'win32'
            await chmod exe, 0o755

        if arch() == 'x64' and platform() == 'linux'
            await chmod path.join(installDir, 'ape-x86_64.elf'), 0o755

        console.log "2048 executable: #{exe}"
        resolve exe

    getSettings: ->
        [
            {
                key: '2048_exe'
                title: '2048 Executable Path'
                description: 'Path to the downloaded 2048 executable.'
                value: await @exe
                readonly: true
            }
        ]

    getDevice: (nativeId) ->
        # Management ui v2's PtyComponent expects the plugin device to implement
        # DeviceProvider and return the StreamService device via getDevice
        this

    connectStream: (input, options) ->
        core = sdk.systemManager.getDeviceByName('@scrypted/core')
        termsvc = await core.getDevice('terminalservice')
        termsvc_direct = await sdk.connectRPCObject termsvc

        exe = await @exe
        if arch() == 'x64' and platform() == 'linux'
            await termsvc_direct.connectStream input,
                cmd: [(path.join (path.dirname exe), 'ape-x86_64.elf'), exe]
        else
            await termsvc_direct.connectStream input,
                cmd: [exe]

export default Scrypted2048Plugin