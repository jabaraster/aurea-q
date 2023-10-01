export default function(ports, functionName, handler) {
    if (!ports) return;
    if (!ports[functionName]) return;
    ports[functionName].subscribe((arg) => {
        console.log(functionName);
        handler(arg);
    });
}